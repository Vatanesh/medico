import 'dart:io';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';

class ChunkUploadService {
  static final ChunkUploadService _instance = ChunkUploadService._internal();
  factory ChunkUploadService() => _instance;
  ChunkUploadService._internal();

  final ApiService _apiService = ApiService();
  
  // Track upload progress
  int _uploadedChunks = 0;
  int _totalChunks = 0;
  
  int get uploadedChunks => _uploadedChunks;
  int get totalChunks => _totalChunks;
  
  // Callback for progress updates
  Function(int uploaded, int total)? onProgressUpdate;

  Future<void> uploadChunk({
    required String sessionId,
    required String chunkPath,
    required int chunkNumber,
    required String mimeType,
  }) async {
    try {
      debugPrint('[CHUNK] Starting upload for chunk $chunkNumber');
      debugPrint('[CHUNK] Session ID: $sessionId');
      debugPrint('[CHUNK] File path: $chunkPath');
      
      _totalChunks = chunkNumber + 1;
      
      // Step 1: Get presigned URL from backend
      debugPrint('[CHUNK] Getting presigned URL...');
      final urlResponse = await _apiService.getPresignedUrl(
        sessionId,
        chunkNumber,
        mimeType,
      );

      final presignedUrl = urlResponse['url'];
      final gcsPath = urlResponse['gcsPath'];
      debugPrint('[CHUNK] Got presigned URL: $presignedUrl');
      debugPrint('[CHUNK] GCS path: $gcsPath');

      // Step 2: Read the audio file
      debugPrint('[CHUNK] Reading audio file...');
      final audioFile = File(chunkPath);
      
      if (!await audioFile.exists()) {
        throw Exception('Audio file does not exist: $chunkPath');
      }
      
      final audioBytes = await audioFile.readAsBytes();
      debugPrint('[CHUNK] Read ${audioBytes.length} bytes from file');

      // Step 3: Upload to presigned URL
      debugPrint('[CHUNK] Uploading to presigned URL...');
      await _apiService.uploadChunk(presignedUrl, audioBytes);
      debugPrint('[CHUNK] Upload successful');

      // Step 4: Notify backend that chunk was uploaded
      debugPrint('[CHUNK] Notifying backend...');
      await _apiService.notifyChunkUploaded({
        'sessionId': sessionId,
        'chunkNumber': chunkNumber,
        'gcsPath': gcsPath,
        'mimeType': mimeType,
        'size': audioBytes.length,
      });
      debugPrint('[CHUNK] Backend notified successfully');

      // Update progress
      _uploadedChunks = chunkNumber + 1;
      debugPrint('[CHUNK] Progress: $_uploadedChunks/$_totalChunks');
      
      if (onProgressUpdate != null) {
        onProgressUpdate!(_uploadedChunks, _totalChunks);
      }

      // Delete local file after successful upload
      try {
        await audioFile.delete();
        debugPrint('[CHUNK] Deleted local file');
      } catch (e) {
        debugPrint('Failed to delete chunk file: $e');
      }

    } catch (e) {
      debugPrint('[CHUNK ERROR] Failed to upload chunk $chunkNumber: $e');
      rethrow;
    }
  }

  void reset() {
    _uploadedChunks = 0;
    _totalChunks = 0;
  }
}
