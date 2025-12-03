import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/queued_chunk.dart';
import 'audio/chunk_upload_service.dart';

class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  final ChunkUploadService _uploadService = ChunkUploadService();
  final Connectivity _connectivity = Connectivity();
  
  Box<QueuedChunk>? _queueBox;
  bool _isProcessing = false;
  bool _isOnline = true;

  Future<void> initialize() async {
    try {
      _queueBox = await Hive.openBox<QueuedChunk>('offline_queue');
      debugPrint('[QUEUE] Initialized with ${_queueBox!.length} queued chunks');
      
      // Monitor network connectivity
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
      
      // Check current connectivity
      final connectivity = await _connectivity.checkConnectivity();
      _isOnline = connectivity != ConnectivityResult.none;
      
      // Process any existing queue
      if (_isOnline) {
        await processQueue();
      }
    } catch (e) {
      debugPrint('[QUEUE ERROR] Failed to initialize: $e');
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOffline = !_isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    debugPrint('[QUEUE] Connectivity changed: $_isOnline');
    
    // If we just came back online, process the queue
    if (wasOffline && _isOnline) {
      debugPrint('[QUEUE] Back online! Processing queued chunks...');
      processQueue();
    }
  }

  Future<void> queueChunk({
    required String sessionId,
    required int chunkNumber,
    required String filePath,
    required String mimeType,
  }) async {
    if (_queueBox == null) {
      debugPrint('[QUEUE ERROR] Queue not initialized');
      return;
    }

    try {
      final chunk = QueuedChunk(
        sessionId: sessionId,
        chunkNumber: chunkNumber,
        filePath: filePath,
        mimeType: mimeType,
        queuedAt: DateTime.now(),
      );

      await _queueBox!.add(chunk);
      debugPrint('[QUEUE] Chunk queued: $chunkNumber for session $sessionId');
      debugPrint('[QUEUE] Total queued: ${_queueBox!.length}');
    } catch (e) {
      debugPrint('[QUEUE ERROR] Failed to queue chunk: $e');
    }
  }

  Future<void> processQueue() async {
    if (_queueBox == null || _isProcessing || !_isOnline) {
      return;
    }

    _isProcessing = true;
    debugPrint('[QUEUE] Processing ${_queueBox!.length} chunks...');

    final chunks = _queueBox!.values.toList();
    
    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      
      // Check if file still exists
      final file = File(chunk.filePath);
      if (!await file.exists()) {
        debugPrint('[QUEUE] File not found, removing from queue: ${chunk.filePath}');
        await chunk.delete();
        continue;
      }

      // Check retry limit
      if (!chunk.shouldRetry) {
        debugPrint('[QUEUE] Chunk exceeded retry limit, removing: ${chunk.chunkNumber}');
        await chunk.delete();
        await file.delete().catchError((_) {});
        continue;
      }

      try {
        debugPrint('[QUEUE] Attempting upload: chunk ${chunk.chunkNumber} (retry ${chunk.retryCount})');
        
        await _uploadService.uploadChunk(
          sessionId: chunk.sessionId,
          chunkPath: chunk.filePath,
          chunkNumber: chunk.chunkNumber,
          mimeType: chunk.mimeType,
        );

        debugPrint('[QUEUE] Successfully uploaded chunk ${chunk.chunkNumber}');
        await chunk.delete();
        
      } catch (e) {
        debugPrint('[QUEUE] Upload failed: $e');
        
        chunk.retryCount++;
        chunk.lastError = e.toString();
        await chunk.save();
        
        // Wait before next retry (exponential backoff)
        await Future.delayed(Duration(seconds: 2 * chunk.retryCount));
      }
    }

    _isProcessing = false;
    debugPrint('[QUEUE] Processing complete. Remaining: ${_queueBox!.length}');
  }

  int get queuedCount => _queueBox?.length ?? 0;
  bool get isOnline => _isOnline;

  Future<void> clearQueue() async {
    if (_queueBox == null) return;
    
    // Delete all associated files
    for (final chunk in _queueBox!.values) {
      try {
        final file = File(chunk.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('[QUEUE] Failed to delete file: $e');
      }
    }
    
    await _queueBox!.clear();
    debugPrint('[QUEUE] Queue cleared');
  }

  void dispose() {
    _queueBox?.close();
  }
}
