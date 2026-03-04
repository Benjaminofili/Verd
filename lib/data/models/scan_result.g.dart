// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually written Hive TypeAdapter for ScanResult

part of 'scan_result.dart';

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 1;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResult(
      id: fields[0] as String,
      userId: fields[1] as String,
      imageUrl: fields[2] as String?,
      localImagePath: fields[3] as String?,
      plantName: fields[4] as String,
      diagnosis: fields[5] as String,
      confidence: fields[6] as double,
      recommendations: (fields[7] as List).cast<String>(),
      scannedAt: fields[8] as DateTime,
      synced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.localImagePath)
      ..writeByte(4)
      ..write(obj.plantName)
      ..writeByte(5)
      ..write(obj.diagnosis)
      ..writeByte(6)
      ..write(obj.confidence)
      ..writeByte(7)
      ..write(obj.recommendations)
      ..writeByte(8)
      ..write(obj.scannedAt)
      ..writeByte(9)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
