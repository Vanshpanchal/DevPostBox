// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_mail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmailAttachmentAdapter extends TypeAdapter<EmailAttachment> {
  @override
  final int typeId = 0;

  @override
  EmailAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmailAttachment(
      filename: fields[0] as String,
      size: fields[1] as int,
      contentType: fields[2] as String,
      downloadUrl: fields[3] as String,
      contentId: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmailAttachment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.filename)
      ..writeByte(1)
      ..write(obj.size)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.downloadUrl)
      ..writeByte(4)
      ..write(obj.contentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmailAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TestMailAdapter extends TypeAdapter<TestMail> {
  @override
  final int typeId = 1;

  @override
  TestMail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TestMail(
      id: fields[0] as String,
      from: fields[1] as String,
      fromName: fields[2] as String,
      fromAddress: fields[3] as String,
      to: fields[4] as String,
      subject: fields[5] as String,
      html: fields[6] as String,
      text: fields[7] as String,
      createdAt: fields[8] as DateTime,
      tag: fields[9] as String,
      namespace: fields[10] as String,
      messageId: fields[11] as String,
      downloadUrl: fields[12] as String,
      attachments: (fields[13] as List).cast<EmailAttachment>(),
      isRead: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TestMail obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.from)
      ..writeByte(2)
      ..write(obj.fromName)
      ..writeByte(3)
      ..write(obj.fromAddress)
      ..writeByte(4)
      ..write(obj.to)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.html)
      ..writeByte(7)
      ..write(obj.text)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.tag)
      ..writeByte(10)
      ..write(obj.namespace)
      ..writeByte(11)
      ..write(obj.messageId)
      ..writeByte(12)
      ..write(obj.downloadUrl)
      ..writeByte(13)
      ..write(obj.attachments)
      ..writeByte(14)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestMailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
