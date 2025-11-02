import 'package:flutter/foundation.dart';
import '../models/daily_data.dart';
import '../models/risk_prediction.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    // Mock initialization for demo
    await Future.delayed(Duration(milliseconds: 100));
    _isInitialized = true;
  }

  Future<RiskPrediction> predictRisk(List<DailyData> weekData) async {
    final stopwatch = Stopwatch()..start();
    
    if (!_isInitialized || weekData.length < 7) {
      return _mockPrediction(stopwatch.elapsedMilliseconds);
    }

    // Simple rule-based prediction for demo
    final features = _prepareFeatures(weekData);
    final riskScore = _calculateRisk(features);
    final category = _getRiskCategory(riskScore);
    final advice = _getAdvice(riskScore, weekData.last);

    stopwatch.stop();

    return RiskPrediction(
      date: DateTime.now(),
      riskScore: riskScore,
      riskCategory: category,
      advice: advice,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  List<double> _prepareFeatures(List<DailyData> weekData) {
    final lastWeek = weekData.take(7).toList();
    
    return [
      lastWeek.map((d) => d.stepsMean).reduce((a, b) => a + b) / 7,
      lastWeek.map((d) => d.stepsStd).reduce((a, b) => a + b) / 7,
      lastWeek.map((d) => d.chargeNightPct).reduce((a, b) => a + b) / 7,
      lastWeek.map((d) => d.smsLoanCount).reduce((a, b) => a + b).toDouble(),
      lastWeek.map((d) => d.idlePeriods).reduce((a, b) => a + b).toDouble(),
    ];
  }

  double _calculateRisk(List<double> features) {
    // Simple rule-based risk calculation
    double mobilityFactor = 1 - (features[0] / 10000).clamp(0.0, 1.0);
    double chargingFactor = features[2];
    double smsFactor = (features[3] / 5).clamp(0.0, 1.0);
    double idleFactor = (features[4] / 7).clamp(0.0, 1.0);
    
    double risk = (0.4 * mobilityFactor + 
                   0.3 * chargingFactor + 
                   0.2 * smsFactor + 
                   0.1 * idleFactor) * 100;
    
    // Add some randomness for demo
    risk += (DateTime.now().millisecond % 20) - 10;
    
    return risk.clamp(0.0, 100.0);
  }

  RiskPrediction _mockPrediction(int inferenceTime) {
    final riskScore = 45.0 + (DateTime.now().millisecond % 40);
    return RiskPrediction(
      date: DateTime.now(),
      riskScore: riskScore,
      riskCategory: _getRiskCategory(riskScore),
      advice: _getAdvice(riskScore, null),
      inferenceTimeMs: inferenceTime,
    );
  }

  String _getRiskCategory(double score) {
    if (score < 30) return 'Low';
    if (score < 70) return 'Medium';
    return 'High';
  }

  String _getAdvice(double riskScore, DailyData? lastDay) {
    if (riskScore > 70) {
      return 'Gura inka imwe kugira ngo ugabanye umuvunyi';
    } else if (riskScore > 40) {
      return 'Ongera genda ku isoko';
    } else {
      return 'Komeza gutyo, uri ku nzira nziza';
    }
  }

  void dispose() {
    // Nothing to dispose in mock version
  }
}
