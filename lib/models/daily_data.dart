import 'package:hive/hive.dart';

part 'daily_data.g.dart';

@HiveType(typeId: 1)
class DailyData extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double stepsMean;

  @HiveField(2)
  double stepsStd;

  @HiveField(3)
  int idlePeriods;

  @HiveField(4)
  double chargeNightPct;

  @HiveField(5)
  int chargeCycles;

  @HiveField(6)
  int smsLoanCount;

  DailyData({
    required this.date,
    required this.stepsMean,
    required this.stepsStd,
    required this.idlePeriods,
    required this.chargeNightPct,
    required this.chargeCycles,
    required this.smsLoanCount,
  });
}
