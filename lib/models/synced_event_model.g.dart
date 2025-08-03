// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'synced_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncedEventAdapter extends TypeAdapter<SyncedEvent> {
  @override
  final int typeId = 10;

  @override
  SyncedEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncedEvent(
      title: fields[0] as String,
      start: fields[1] as DateTime,
      end: fields[2] as DateTime,
      location: fields[3] as String,
      link: fields[4] as String,
      source: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SyncedEvent obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.link)
      ..writeByte(5)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncedEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
