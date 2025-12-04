import 'package:flutter/material.dart';
import 'dart:async';
import '../models/session.dart';
import '../services/api/api_service.dart';
import '../services/audio/audio_recorder_service.dart';
import '../services/audio/chunk_upload_service.dart';
import '../services/offline_queue_service.dart';
import '../services/native_recording_service.dart';
import '../services/session_storage_service.dart';
import '../core/constants/api_endpoints.dart';

enum RecordingState { idle, recording, paused }

class RecordingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioRecorderService _audioService = AudioRecorderService();
  final ChunkUploadService _uploadService = ChunkUploadService();
  final OfflineQueueService _queueService = OfflineQueueService();
  
  RecordingState _state = RecordingState.idle;
  RecordingSession? _currentSession;
  int _chunksUploaded = 0;
  int _totalChunks = 0;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  double _audioLevel = 0.0;
  bool _isOnline = true;
  bool _pausedByPhoneCall = false; // Track if paused by phone call
  
  // Getters
  RecordingState get state => _state;
  RecordingSession? get currentSession => _currentSession;
  int get chunksUploaded => _chunksUploaded;
  int get totalChunks => _totalChunks;
  Duration get recordingDuration => _recordingDuration;
  double get audioLevel => _audioLevel;
  bool get isOnline => _isOnline;
  bool get isRecording => _state == RecordingState.recording;
  bool get isPaused => _state == RecordingState.paused;
  int get queuedChunks => _queueService.queuedCount;
  bool get pausedByPhoneCall => _pausedByPhoneCall;
  double get gain => _audioService.gain; // Expose gain from service
  List<double> get amplitudeHistory => List.unmodifiable(_amplitudeHistory);
  
  final List<double> _amplitudeHistory = [];
  static const int _maxHistoryLength = 100; // Keep last 100 points for the waveform

  String get formattedDuration {
    final hours = _recordingDuration.inHours;
    final minutes = _recordingDuration.inMinutes.remainder(60);
    final seconds = _recordingDuration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  RecordingProvider() {
    // Initialize native service callbacks
    NativeRecordingService.initialize();
    NativeRecordingService.onPause = _handleNativePause;
    NativeRecordingService.onResume = _handleNativeResume;
    NativeRecordingService.onStop = _handleNativeStop;
    NativeRecordingService.onPhoneCallStarted = _handlePhoneCallStarted;
    NativeRecordingService.onPhoneCallEnded = _handlePhoneCallEnded;
    
    // Set up audio service callbacks
    _audioService.onChunkReady = _handleChunkReady;
    _audioService.onAmplitudeUpdate = _handleAmplitudeUpdate;
    
    // Set up upload service callback
    _uploadService.onProgressUpdate = _handleUploadProgress;
    
    // Initialize offline queue
    _initializeQueue();
    
    // Initialize session storage
    _initializeStorage();
  }
  
  Future<void> _initializeStorage() async {
    await SessionStorageService().initialize();
  }
  
  Future<void> checkRecovery(String currentUserId) async {
    final session = SessionStorageService().getActiveSession();
    if (session != null) {
      // Check if session belongs to current user
      if (session.userId != currentUserId) {
        debugPrint('[PROVIDER] Found session for different user (${session.userId}), clearing...');
        await SessionStorageService().clearSession();
        return;
      }

      debugPrint('[PROVIDER] Found interrupted session: ${session.id}');
      
      // Restore session
      _currentSession = session;
      _state = RecordingState.paused;
      
      // Restore duration
      final savedDuration = SessionStorageService().getSavedDuration();
      _recordingDuration = Duration(seconds: savedDuration);
      
      // Attempt to recover the last chunk
      final chunkPath = SessionStorageService().getCurrentChunkPath();
      final chunkNumber = SessionStorageService().getCurrentChunkNumber();
      
      if (chunkPath != null && chunkNumber != null) {
        final recovered = await _audioService.recoverInterruptedRecording(chunkPath);
        if (recovered) {
          debugPrint('[PROVIDER] Recovered interrupted chunk #$chunkNumber');
          
          // Queue for upload
          await _queueService.queueChunk(
            sessionId: session.id,
            chunkNumber: chunkNumber,
            filePath: chunkPath,
            mimeType: AppConstants.audioMimeType,
          );
          
          // Trigger queue processing immediately
          _queueService.processQueue();
        }
      }
      
      notifyListeners();
    }
  }
  
  // Handlers for notification actions from native service
  void _handleNativePause() async {
    debugPrint('[PROVIDER] Handling pause from notification');
    await _audioService.pauseRecording();
    _pauseRecordingInternal();
  }

  void _handleNativeResume() async {
    debugPrint('[PROVIDER] Handling resume from notification');
    await _audioService.resumeRecording();
    _resumeRecordingInternal();
  }

  void _handleNativeStop() async {
    debugPrint('[PROVIDER] Handling stop from notification');
    await _audioService.stopRecording();
    _stopRecordingInternal();
  }
  
  // Handlers for phone call interruptions
  void _handlePhoneCallStarted() async {
    debugPrint('[PROVIDER] Phone call started - auto-pausing recording');
    if (_state == RecordingState.recording) {
      await _audioService.pauseRecording();
      _pausedByPhoneCall = true;
      _pauseRecordingInternal();
    }
  }
  
  void _handlePhoneCallEnded() async {
    debugPrint('[PROVIDER] Phone call ended');
    // Auto-resume if paused by phone call
    if (_state == RecordingState.paused && _pausedByPhoneCall) {
      debugPrint('[PROVIDER] Auto-resuming recording after call');
      await _audioService.resumeRecording();
      _pausedByPhoneCall = false;
      _resumeRecordingInternal();
    }
  }

  Future<void> _initializeQueue() async {
    await _queueService.initialize();
    _updateNetworkStatus();
    notifyListeners();
  }

  void _updateNetworkStatus() {
    final wasOnline = _isOnline;
    _isOnline = _queueService.isOnline;
    
    if (wasOnline != _isOnline) {
      debugPrint('[PROVIDER] Network status changed: $_isOnline');
      notifyListeners();
    }
  }

  Future<void> startRecording({
    required String userId,
    required String patientId,
    required String patientName,
    String? templateId,
  }) async {
    try {
      // Check if already recording for another patient
      if (_currentSession != null && _currentSession!.patientId != patientId) {
        throw Exception('Cannot start new recording. Active session exists for ${_currentSession!.patientName}');
      }

      // Check microphone permission
      final hasPermission = await _audioService.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission required');
      }

      // Create session on backend
      final sessionId = await _apiService.createSession({
        'userId': userId,
        'patientId': patientId,
        'patientName': patientName,
        'status': 'recording',
        'startTime': DateTime.now().toIso8601String(),
        'templateId': templateId,
      });

      _currentSession = RecordingSession(
        id: sessionId,
        userId: userId,
        patientId: patientId,
        patientName: patientName,
        status: 'recording',
        startTime: DateTime.now(),
        templateId: templateId,
      );

      // Start native foreground service (Android)
      try {
        // Request notification permission for Android 13+
        final hasNotificationPermission = await NativeRecordingService.requestNotificationPermission();
        if (!hasNotificationPermission) {
          throw Exception('Notification permission required for background recording');
        }
        
        // Request phone state permission for call detection (non-blocking)
        final hasPhonePermission = await NativeRecordingService.requestPhoneStatePermission();
        if (!hasPhonePermission) {
          debugPrint('[PROVIDER] Phone state permission denied - call detection may not work');
        }
        
        await NativeRecordingService.startService();
      } catch (e) {
        debugPrint('[PROVIDER] Native service failed: $e');
        // Throw error if notification permission denied
        if (e.toString().contains('Notification permission')) {
          rethrow;
        }
        // Continue anyway for other errors - service is optional
      }

      // Start audio recording
      await _audioService.startRecording(sessionId);

      _state = RecordingState.recording;
      _recordingDuration = Duration.zero;
      _uploadService.reset();
      
      // Start timer
      _startTimer();
      
      // Save session state
      await SessionStorageService().saveSession(_currentSession!);
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void _handleChunkReady(String chunkPath, int chunkNumber, bool isLast) {
    // Upload chunk in background
    if (_currentSession != null) {
      _uploadService.uploadChunk(
        sessionId: _currentSession!.id,
        chunkPath: chunkPath,
        chunkNumber: chunkNumber,
        mimeType: AppConstants.audioMimeType,
        isLast: isLast,
      ).catchError((error) {
        debugPrint('[PROVIDER] Chunk upload failed: $error');
        
        // Queue for retry if network issue
        _queueService.queueChunk(
          sessionId: _currentSession!.id,
          filePath: chunkPath,
          chunkNumber: chunkNumber,
          mimeType: AppConstants.audioMimeType,
        );
      });
    }
  }

  void _handleAmplitudeUpdate(double amplitude) {
    _audioLevel = amplitude;
    
    // Add to history
    _amplitudeHistory.add(amplitude);
    if (_amplitudeHistory.length > _maxHistoryLength) {
      _amplitudeHistory.removeAt(0);
    }
    
    notifyListeners();
  }

  void _handleUploadProgress(int uploaded, int total) {
    _chunksUploaded = uploaded;
    _totalChunks = total;
    _updateNetworkStatus(); // Check network status on each upload
    notifyListeners();
  }

  void setGain(double value) {
    _audioService.setGain(value);
    notifyListeners();
  }

  // Public methods (called from UI)
  Future<void> pauseRecording() async {
    await _audioService.pauseRecording();
    try {
      await NativeRecordingService.pauseService();
    } catch (e) {
      debugPrint('[PROVIDER] Native pause failed: $e');
    }
    _pausedByPhoneCall = false; // Clear phone call flag for manual pause
    _pauseRecordingInternal();
  }
  
  // Internal method (called from notification callback or after native call)
  void _pauseRecordingInternal() {
    _state = RecordingState.paused;
    _stopTimer();
    notifyListeners();
  }

  Future<void> resumeRecording() async {
    // Check if we need to perform a "hard resume" (recovery from crash)
    if (_audioService.state == RecorderState.idle && _currentSession != null) {
      debugPrint('[PROVIDER] Performing hard resume for session ${_currentSession!.id}');
      
      // Determine the next chunk number
      // If we recovered chunk #N, we should start at #N+1
      int nextChunkNumber = 0;
      final lastChunkNumber = SessionStorageService().getCurrentChunkNumber();
      if (lastChunkNumber != null) {
        nextChunkNumber = lastChunkNumber + 1;
      }
      
      // Start recording (this will start a new stream but continue the session)
      await _audioService.startRecording(
        _currentSession!.id,
        startChunkNumber: nextChunkNumber,
      );
      
      // Also start native service
      try {
        await NativeRecordingService.startService();
      } catch (e) {
        debugPrint('[PROVIDER] Native start failed during recovery: $e');
      }
    } else {
      // Normal resume
      await _audioService.resumeRecording();
      try {
        await NativeRecordingService.resumeService();
      } catch (e) {
        debugPrint('[PROVIDER] Native resume failed: $e');
      }
    }
    
    _resumeRecordingInternal();
  }
  
  void _resumeRecordingInternal() {
    _state = RecordingState.recording;
    _startTimer();
    notifyListeners();
  }

  Future<void> stopRecording() async {
    await _audioService.stopRecording();
    try {
      await NativeRecordingService.stopService();
    } catch (e) {
      debugPrint('[PROVIDER] Native stop failed: $e');
    }
    _stopRecordingInternal();
  }
  
  void _stopRecordingInternal() {
    _state = RecordingState.idle;
    _stopTimer();
    _currentSession = null;
    _recordingDuration = Duration.zero;
    _chunksUploaded = 0;
    _totalChunks = 0;
    _audioLevel = 0.0;
    _amplitudeHistory.clear();
    SessionStorageService().clearSession();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration += const Duration(seconds: 1);
      SessionStorageService().saveDuration(_recordingDuration.inSeconds);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void updateNetworkStatus(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
