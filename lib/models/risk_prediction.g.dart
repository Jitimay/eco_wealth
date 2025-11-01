// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'risk_prediction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RiskPredictionAdapter extends TypeAdapter<RiskPrediction> {
  @override
  final int typeId = 2;

  @override
  RiskPrediction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RiskPrediction(
      date: fields[0] as DateTime,
      riskScore: fields[1] as double,
      riskCategory: fields[2] as String,
      advice: fields[3] as String,
      inferenceTimeMs: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RiskPrediction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.riskScore)
      ..writeByte(2)
      ..write(obj.riskCategory)
      ..writeByte(3)
      ..write(obj.advice)
      ..writeByte(4)
      ..write(obj.inferenceTimeMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskPredictionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
