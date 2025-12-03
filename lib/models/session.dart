class RecordingSession {
  final String id;
  final String userId;
  final String patientId;
  final String patientName;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final String? duration;
  final String? templateId;
  final String? sessionTitle;
  final String? sessionSummary;
  final String? transcript;
  final String? transcriptStatus;
  final List<AudioChunkMetadata> chunks;
  final int totalChunks;
  final bool isComplete;

  RecordingSession({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.patientName,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    this.templateId,
    this.sessionTitle,
    this.sessionSummary,
    this.transcript,
    this.transcriptStatus,
    this.chunks = const [],
    this.totalChunks = 0,
    this.isComplete = false,
  });

  factory RecordingSession.fromJson(Map<String, dynamic> json) {
    return RecordingSession(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['user_id'] ?? '',
      patientId: json['patient_id'] ?? '',
      patientName: json['patientName'] ?? json['patient_name'] ?? '',
      status: json['status'] ?? 'recording',
      startTime: DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      duration: json['duration'],
      templateId: json['templateId'],
      sessionTitle: json['session_title'],
      sessionSummary: json['session_summary'],
      transcript: json['transcript'],
      transcriptStatus: json['transcript_status'],
      chunks: (json['chunks'] as List<dynamic>?)
              ?.map((c) => AudioChunkMetadata.fromJson(c))
              .toList() ??
          [],
      totalChunks: json['totalChunks'] ?? 0,
      isComplete: json['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'patient_id': patientId,
      'patientName': patientName,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration,
      'templateId': templateId,
      'session_title': sessionTitle,
      'session_summary': sessionSummary,
      'transcript': transcript,
      'transcript_status': transcriptStatus,
      'chunks': chunks.map((c) => c.toJson()).toList(),
      'totalChunks': totalChunks,
      'isComplete': isComplete,
    };
  }
}

class AudioChunkMetadata {
  final int chunkNumber;
  final String gcsPath;
  final String? publicUrl;
  final String mimeType;
  final DateTime uploadedAt;
  final int? size;

  AudioChunkMetadata({
    required this.chunkNumber,
    required this.gcsPath,
    this.publicUrl,
    required this.mimeType,
    required this.uploadedAt,
    this.size,
  });

  factory AudioChunkMetadata.fromJson(Map<String, dynamic> json) {
    return AudioChunkMetadata(
      chunkNumber: json['chunkNumber'] ?? 0,
      gcsPath: json['gcsPath'] ?? '',
      publicUrl: json['publicUrl'],
      mimeType: json['mimeType'] ?? 'audio/wav',
      uploadedAt: DateTime.parse(json['uploadedAt'] ?? DateTime.now().toIso8601String()),
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chunkNumber': chunkNumber,
      'gcsPath': gcsPath,
      'publicUrl': publicUrl,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
      'size': size,
    };
  }
}
