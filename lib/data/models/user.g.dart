// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually written Hive TypeAdapter for AppUser

part of 'user.dart';

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String,
      photoUrl: fields[3] as String?,
      farmLocation: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      phoneNumber: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.farmLocation)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
