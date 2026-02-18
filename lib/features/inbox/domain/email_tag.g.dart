// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailTagAdapter extends TypeAdapter<EmailTag> {
  @override
  final int typeId = 2;

  @override
  EmailTag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmailTag(
      id: fields[0] as String,
      name: fields[1] as String,
      color: fields[2] as String,
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, EmailTag obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
