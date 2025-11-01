import 'package:hive/hive.dart';

part 'risk_prediction.g.dart';

@HiveType(typeId: 2)
class RiskPrediction extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double riskScore;

  @HiveField(2)
  String riskCategory;

  @HiveField(3)
  String advice;

  @HiveField(4)
  int inferenceTimeMs;

  RiskPrediction({
    required this.date,
    required this.riskScore,
    required this.riskCategory,
    required this.advice,
    required this.inferenceTimeMs,
  });

  String get riskCategoryKirundi {
    switch (riskCategory) {
      case 'Low':
        return 'Nkeya';
      case 'Medium':
        return 'Hagati';
      case 'High':
        return 'Nkuru';
      default:
        return riskCategory;
    }
  }
}
