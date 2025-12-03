import 'package:hive/hive.dart';

part 'audio_chunk.g.dart';

@HiveType(typeId: 0)
class AudioChunk extends HiveObject {
  @HiveField(0)
  final String sessionId;
  
  @HiveField(1)
  final int chunkNumber;
  
  @HiveField(2)
  final String localPath;
  
  @HiveField(3)
  final String mimeType;
  
  @HiveField(4)
  final int size;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  String status; // 'pending', 'uploading', 'uploaded', 'failed'
  
  @HiveField(7)
  String? gcsPath;
  
  @HiveField(8)
  String? publicUrl;
  
  @HiveField(9)
  int retryCount;

  AudioChunk({
    required this.sessionId,
    required this.chunkNumber,
    required this.localPath,
    required this.mimeType,
    required this.size,
    required this.createdAt,
    this.status = 'pending',
    this.gcsPath,
    this.publicUrl,
    this.retryCount = 0,
  });
}
