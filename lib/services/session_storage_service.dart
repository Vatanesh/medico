import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/session.dart';

class SessionStorageService {
  static final SessionStorageService _instance = SessionStorageService._internal();
  factory SessionStorageService() => _instance;
  SessionStorageService._internal();

  Box? _sessionBox;
  static const String _boxName = 'active_session';
  static const String _keySession = 'current_session';
  static const String _keyChunkPath = 'current_chunk_path';
  static const String _keyChunkNumber = 'current_chunk_number';
  static const String _keyDuration = 'current_duration';

  Future<void> initialize() async {
    try {
      _sessionBox = await Hive.openBox(_boxName);
      debugPrint('[SESSION STORAGE] Initialized');
    } catch (e) {
      debugPrint('[SESSION STORAGE ERROR] Failed to initialize: $e');
    }
  }

  Future<void> saveSession(RecordingSession session) async {
    if (_sessionBox == null) return;
    try {
      await _sessionBox!.put(_keySession, session.toJson());
      debugPrint('[SESSION STORAGE] Session saved: ${session.id}');
    } catch (e) {
      debugPrint('[SESSION STORAGE ERROR] Failed to save session: $e');
    }
  }

  Future<void> saveCurrentChunkInfo(String path, int number) async {
    if (_sessionBox == null) return;
    try {
      await _sessionBox!.put(_keyChunkPath, path);
      await _sessionBox!.put(_keyChunkNumber, number);
      debugPrint('[SESSION STORAGE] Chunk info saved: #$number at $path');
    } catch (e) {
      debugPrint('[SESSION STORAGE ERROR] Failed to save chunk info: $e');
    }
  }

  Future<void> saveDuration(int durationSeconds) async {
    if (_sessionBox == null) return;
    try {
      await _sessionBox!.put(_keyDuration, durationSeconds);
    } catch (e) {
      // Ignore errors for frequent updates
    }
  }

  Future<void> clearSession() async {
    if (_sessionBox == null) return;
    try {
      await _sessionBox!.clear();
      debugPrint('[SESSION STORAGE] Session cleared');
    } catch (e) {
      debugPrint('[SESSION STORAGE ERROR] Failed to clear session: $e');
    }
  }

  RecordingSession? getActiveSession() {
    if (_sessionBox == null) return null;
    try {
      final json = _sessionBox!.get(_keySession);
      if (json != null) {
        // Cast to Map<String, dynamic> safely
        final map = Map<String, dynamic>.from(json as Map);
        return RecordingSession.fromJson(map);
      }
    } catch (e) {
      debugPrint('[SESSION STORAGE ERROR] Failed to get session: $e');
    }
    return null;
  }

  String? getCurrentChunkPath() {
    return _sessionBox?.get(_keyChunkPath) as String?;
  }

  int? getCurrentChunkNumber() {
    return _sessionBox?.get(_keyChunkNumber) as int?;
  }

  int getSavedDuration() {
    return (_sessionBox?.get(_keyDuration) as int?) ?? 0;
  }
}
