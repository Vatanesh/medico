// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_chunk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedChunkAdapter extends TypeAdapter<QueuedChunk> {
  @override
  final int typeId = 0;

  @override
  QueuedChunk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedChunk(
      sessionId: fields[0] as String,
      chunkNumber: fields[1] as int,
      filePath: fields[2] as String,
      mimeType: fields[3] as String,
      retryCount: fields[4] as int,
      queuedAt: fields[5] as DateTime,
      lastError: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedChunk obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.chunkNumber)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.retryCount)
      ..writeByte(5)
      ..write(obj.queuedAt)
      ..writeByte(6)
      ..write(obj.lastError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedChunkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
