import 'package:hive/hive.dart';

part 'queued_chunk.g.dart';

@HiveType(typeId: 0)
class QueuedChunk extends HiveObject {
  @HiveField(0)
  String sessionId;

  @HiveField(1)
  int chunkNumber;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  String mimeType;

  @HiveField(4)
  int retryCount;

  @HiveField(5)
  DateTime queuedAt;

  @HiveField(6)
  String? lastError;

  QueuedChunk({
    required this.sessionId,
    required this.chunkNumber,
    required this.filePath,
    required this.mimeType,
    this.retryCount = 0,
    required this.queuedAt,
    this.lastError,
  });

  bool get shouldRetry => retryCount < 3;

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'chunkNumber': chunkNumber,
        'filePath': filePath,
        'mimeType': mimeType,
        'retryCount': retryCount,
        'queuedAt': queuedAt.toIso8601String(),
        'lastError': lastError,
      };
}
