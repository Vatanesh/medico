import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as dart_math;
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../session_storage_service.dart';
import '../../core/constants/api_endpoints.dart';

enum RecorderState { idle, recording, paused, stopped }

class AudioRecorderService {
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  RecorderState _state = RecorderState.idle;
  Timer? _chunkTimer;
  String? _currentSessionId;
  int _chunkCounter = 0;
  String? _currentRecordingPath;
  IOSink? _currentFileSink;
  int _currentChunkSize = 0;
  int _audioDataCount = 0; // Track how many times we receive audio data
  
  RecorderState get state => _state;
  double get gain => _gain;
  
  // Callback for when a chunk is ready
  Function(String path, int chunkNumber, bool isLast)? onChunkReady;
  
  // Callback for audio amplitude updates
  Function(double amplitude)? onAmplitudeUpdate;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording(String sessionId, {int startChunkNumber = 0}) async {
    if (_state != RecorderState.idle) {
      throw Exception('Recorder is already in use');
    }

    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    _currentSessionId = sessionId;
    _chunkCounter = startChunkNumber;
    _state = RecorderState.recording;

    // Start the stream
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: AppConstants.sampleRate,
        numChannels: 1,
      ),
    );

    // Listen to the stream
    stream.listen(
      (data) {
        _handleAudioData(data);
      },
      onError: (e) {
        debugPrint('[RECORDER] Stream error: $e');
      },
      onDone: () {
        debugPrint('[RECORDER] Stream closed');
      },
    );

    // Start the first chunk file
    await _startNewChunk();

    // Set up timer to create chunks every 15 seconds
    _chunkTimer = Timer.periodic(AppConstants.chunkDuration, (timer) async {
      if (_state == RecorderState.recording) {
        await _finalizeChunk();
        await _startNewChunk();
      }
    });
  }

  double _gain = 1.0;

  void setGain(double value) {
    _gain = value.clamp(0.0, 4.0); // Limit gain between 0x and 4x
    debugPrint('[RECORDER] Gain set to $_gain');
  }

  void _handleAudioData(Uint8List data) {
    if (_state != RecorderState.recording) {
      debugPrint('[RECORDER] ⚠️ Skipping data, state is $_state');
      return;
    }

    _audioDataCount++;
    
    // Log every 50th data packet to avoid spam
    if (_audioDataCount % 50 == 0) {
      debugPrint('[RECORDER] 📊 Received ${data.length} bytes (packet #$_audioDataCount, total chunk size: $_currentChunkSize)');
    }

    // Apply gain if needed (and if we have PCM 16-bit data)
    Uint8List processedData = data;
    if (_gain != 1.0) {
      // Create a new buffer for processed data
      final buffer = ByteData.sublistView(data);
      final newBuffer = ByteData(data.length);
      
      for (int i = 0; i < data.length; i += 2) {
        if (i + 1 < data.length) {
          // Read 16-bit sample
          int sample = buffer.getInt16(i, Endian.little);
          
          // Apply gain
          int amplifiedSample = (sample * _gain).round();
          
          // Clamp to 16-bit range
          amplifiedSample = amplifiedSample.clamp(-32768, 32767);
          
          // Write back
          newBuffer.setInt16(i, amplifiedSample, Endian.little);
        }
      }
      processedData = newBuffer.buffer.asUint8List();
    }

    // Write audio data to file for chunked upload
    if (_currentFileSink != null) {
      _currentFileSink!.add(processedData);
      _currentChunkSize += processedData.length;
    } else {
      debugPrint('[RECORDER] ⚠️ No file sink available! Data lost.');
    }

    // Calculate amplitude for visual feedback
    if (onAmplitudeUpdate != null && processedData.isNotEmpty) {
      double sumSquare = 0;
      for (int i = 0; i < processedData.length; i += 2) {
        if (i + 1 < processedData.length) {
          int sample = processedData[i] | (processedData[i + 1] << 8);
          if (sample > 32767) sample -= 65536;
          sumSquare += sample * sample;
        }
      }
      final meanSquare = (sumSquare / (processedData.length / 2));
      final rms = dart_math.sqrt(meanSquare);
      // Normalize to 0.0 - 1.0 (max amplitude is 32768)
      // Multiply by 3.0 to boost normal speech levels for better visualization
      final amplitude = (rms / 32768.0 * 3.0).clamp(0.0, 1.0);
      onAmplitudeUpdate!(amplitude);
    }
  }

  Future<void> _startNewChunk() async {
    final directory = await getApplicationDocumentsDirectory();
    _currentRecordingPath = '${directory.path}/${_currentSessionId}_chunk_${_chunkCounter}.wav';
    
    debugPrint('[RECORDER] 🆕 Starting new chunk #$_chunkCounter');
    debugPrint('[RECORDER] 📁 Path: $_currentRecordingPath');
    
    final file = File(_currentRecordingPath!);
    _currentFileSink = file.openWrite();
    _currentChunkSize = 0;
    _audioDataCount = 0; // Reset counter for new chunk
    
    // Write WAV header placeholder (44 bytes)
    _currentFileSink!.add(Uint8List(44));
    
    // Save chunk info for recovery
    await SessionStorageService().saveCurrentChunkInfo(_currentRecordingPath!, _chunkCounter);
    
    debugPrint('[RECORDER] ✅ Chunk file opened, WAV header written');
  }

  Future<void> _finalizeChunk({bool isLast = false}) async {
    if (_currentFileSink == null) {
      debugPrint('[RECORDER] ⚠️ Cannot finalize - no active chunk');
      return;
    }

    debugPrint('[RECORDER] 🏁 Finalizing chunk #$_chunkCounter${isLast ? " (LAST)" : ""}');
    debugPrint('[RECORDER] 📊 Total audio data size: $_currentChunkSize bytes');
    debugPrint('[RECORDER] 📊 Audio packets received: $_audioDataCount');

    // Close the file sink FIRST
    await _currentFileSink!.flush(); // Ensure all data written
    await _currentFileSink!.close();
    _currentFileSink = null;

    // Update WAV header with correct sizes
    if (_currentRecordingPath != null) {
      await _updateWavHeader(_currentRecordingPath!, _currentChunkSize);
      
      // Verify actual file size
      final file = File(_currentRecordingPath!);
      final actualSize = await file.length();
      debugPrint('[RECORDER] ✅ WAV header updated');
      debugPrint('[RECORDER] 📏 Actual file size on disk: $actualSize bytes');
      debugPrint('[RECORDER] 📤 Triggering upload for chunk #$_chunkCounter');
      
      if (actualSize < 1000) {
        debugPrint('[RECORDER] ⚠️⚠️⚠️ WARNING: File is too small! Expected ${_currentChunkSize + 44} bytes');
      }
      
      if (onChunkReady != null) {
        onChunkReady!(_currentRecordingPath!, _chunkCounter, isLast);
        _chunkCounter++;
      }
    }
  }

  Future<void> _updateWavHeader(String path, int dataSize) async {
    final file = File(path);
    if (!await file.exists()) return;

    // Use RandomAccessFile to update header without truncating
    final raf = await file.open(mode: FileMode.append);
    await raf.setPosition(0);
    
    final header = _createWavHeader(dataSize);
    await raf.writeFrom(header);
    await raf.close();
  }

  Uint8List _createWavHeader(int dataSize) {
    final buffer = ByteData(44);
    final fileSize = dataSize + 36;
    final sampleRate = AppConstants.sampleRate;
    final channels = 1;
    final byteRate = sampleRate * channels * 2; // 16-bit = 2 bytes

    // RIFF chunk
    buffer.setUint8(0, 0x52); // R
    buffer.setUint8(1, 0x49); // I
    buffer.setUint8(2, 0x46); // F
    buffer.setUint8(3, 0x46); // F
    buffer.setUint32(4, fileSize, Endian.little);
    buffer.setUint8(8, 0x57); // W
    buffer.setUint8(9, 0x41); // A
    buffer.setUint8(10, 0x56); // V
    buffer.setUint8(11, 0x45); // E

    // fmt chunk
    buffer.setUint8(12, 0x66); // f
    buffer.setUint8(13, 0x6d); // m
    buffer.setUint8(14, 0x74); // t
    buffer.setUint8(15, 0x20); // space
    buffer.setUint32(16, 16, Endian.little); // Chunk size
    buffer.setUint16(20, 1, Endian.little); // Audio format (1 = PCM)
    buffer.setUint16(22, channels, Endian.little);
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, channels * 2, Endian.little); // Block align
    buffer.setUint16(34, 16, Endian.little); // Bits per sample

    // data chunk
    buffer.setUint8(36, 0x64); // d
    buffer.setUint8(37, 0x61); // a
    buffer.setUint8(38, 0x74); // t
    buffer.setUint8(39, 0x61); // a
    buffer.setUint32(40, dataSize, Endian.little);

    return buffer.buffer.asUint8List();
  }

  Future<void> pauseRecording() async {
    if (_state != RecorderState.recording) return;
    _state = RecorderState.paused;
    _chunkTimer?.cancel();
  }

  Future<void> resumeRecording() async {
    if (_state != RecorderState.paused) return;
    
    _state = RecorderState.recording;
    
    // Restart chunk timer
    _chunkTimer = Timer.periodic(AppConstants.chunkDuration, (timer) async {
      if (_state == RecorderState.recording) {
        await _finalizeChunk();
        await _startNewChunk();
      }
    });
  }

  Future<void> stopRecording() async {
    if (_state == RecorderState.idle) return;

    _chunkTimer?.cancel();
    await _recorder.stop(); // Stop the stream
    
    // Finalize the last chunk with isLast flag
    await _finalizeChunk(isLast: true);

    _state = RecorderState.stopped;
    _currentSessionId = null;
    _currentRecordingPath = null;
    _chunkCounter = 0;
    
    await Future.delayed(const Duration(milliseconds: 100));
    _state = RecorderState.idle;
  }

  Future<bool> recoverInterruptedRecording(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      debugPrint('[RECORDER] Recovery failed: File not found at $path');
      return false;
    }

    try {
      final length = await file.length();
      if (length <= 44) {
        debugPrint('[RECORDER] Recovery failed: File too small ($length bytes)');
        return false;
      }

      final dataSize = length - 44;
      await _updateWavHeader(path, dataSize.toInt());
      debugPrint('[RECORDER] ✅ Recovered interrupted file: $path ($dataSize bytes)');
      return true;
    } catch (e) {
      debugPrint('[RECORDER] Recovery failed: $e');
      return false;
    }
  }

  void dispose() {
    _chunkTimer?.cancel();
    _recorder.dispose();
  }
}
