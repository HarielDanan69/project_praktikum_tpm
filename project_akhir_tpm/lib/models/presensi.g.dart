// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresensiAdapter extends TypeAdapter<Presensi> {
  @override
  final int typeId = 2;

  @override
  Presensi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Presensi(
      id: fields[0] as String?,
      tgl: fields[1] as String,
      kehadiran: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Presensi obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tgl)
      ..writeByte(2)
      ..write(obj.kehadiran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresensiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
