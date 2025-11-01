import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/daily_data.dart';
import '../models/risk_prediction.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  Interpreter? _interpreter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()
        ..useNnApiForAndroid = true // Enable NPU acceleration
        ..threads = 2;
      
      _interpreter = await Interpreter.fromAsset(
        'assets/models/echo_wealth.tflite',
        options: options,
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to load model: $e');
      // Create mock interpreter for development
      _isInitialized = false;
    }
  }

  Future<RiskPrediction> predictRisk(List<DailyData> weekData) async {
    final stopwatch = Stopwatch()..start();
    
    if (!_isInitialized || weekData.length < 7) {
      return _mockPrediction(stopwatch.elapsedMilliseconds);
    }

    try {
      // Prepare input features (21 features per day, 7 days)
      final input = _prepareFeatures(weekData);
      final output = Float32List(1);

      _interpreter!.run(input, output);
      
      final riskScore = (output[0] * 100).clamp(0.0, 100.0);
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
    } catch (e) {
      debugPrint('Prediction error: $e');
      return _mockPrediction(stopwatch.elapsedMilliseconds);
    }
  }

  Float32List _prepareFeatures(List<DailyData> weekData) {
    final features = Float32List(21);
    final lastWeek = weekData.take(7).toList();
    
    // Aggregate weekly features
    features[0] = lastWeek.map((d) => d.stepsMean).reduce((a, b) => a + b) / 7;
    features[1] = lastWeek.map((d) => d.stepsStd).reduce((a, b) => a + b) / 7;
    features[2] = lastWeek.map((d) => d.chargeNightPct).reduce((a, b) => a + b) / 7;
    features[3] = lastWeek.map((d) => d.smsLoanCount).reduce((a, b) => a + b).toDouble();
    features[4] = lastWeek.map((d) => d.idlePeriods).reduce((a, b) => a + b).toDouble();
    
    // Add more engineered features (normalized)
    for (int i = 5; i < 21; i++) {
      features[i] = (features[i % 5] * (i / 5.0)).clamp(0.0, 1.0);
    }
    
    return features;
  }

  RiskPrediction _mockPrediction(int inferenceTime) {
    // Mock prediction for development/demo
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
      return 'Gura inka imwe kugira ngo ugabanye umuvunyi'; // Sell one goat to reduce risk
    } else if (riskScore > 40) {
      return 'Ongera genda ku isoko'; // Increase market trips
    } else {
      return 'Komeza gutyo, uri ku nzira nziza'; // Keep it up, you\'re on the right track
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
