// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyDataAdapter extends TypeAdapter<DailyData> {
  @override
  final int typeId = 1;

  @override
  DailyData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyData(
      date: fields[0] as DateTime,
      stepsMean: fields[1] as double,
      stepsStd: fields[2] as double,
      idlePeriods: fields[3] as int,
      chargeNightPct: fields[4] as double,
      chargeCycles: fields[5] as int,
      smsLoanCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyData obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.stepsMean)
      ..writeByte(2)
      ..write(obj.stepsStd)
      ..writeByte(3)
      ..write(obj.idlePeriods)
      ..writeByte(4)
      ..write(obj.chargeNightPct)
      ..writeByte(5)
      ..write(obj.chargeCycles)
      ..writeByte(6)
      ..write(obj.smsLoanCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
