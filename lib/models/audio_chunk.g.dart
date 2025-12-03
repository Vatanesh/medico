// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_chunk.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioChunkAdapter extends TypeAdapter<AudioChunk> {
  @override
  final int typeId = 0;

  @override
  AudioChunk read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioChunk(
      sessionId: fields[0] as String,
      chunkNumber: fields[1] as int,
      localPath: fields[2] as String,
      mimeType: fields[3] as String,
      size: fields[4] as int,
      createdAt: fields[5] as DateTime,
      status: fields[6] as String,
      gcsPath: fields[7] as String?,
      publicUrl: fields[8] as String?,
      retryCount: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AudioChunk obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.chunkNumber)
      ..writeByte(2)
      ..write(obj.localPath)
      ..writeByte(3)
      ..write(obj.mimeType)
      ..writeByte(4)
      ..write(obj.size)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.gcsPath)
      ..writeByte(8)
      ..write(obj.publicUrl)
      ..writeByte(9)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioChunkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
