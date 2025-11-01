import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:telephony/telephony.dart';
import '../models/daily_data.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  final Battery _battery = Battery();
  final Telephony _telephony = Telephony.instance;
  
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  final List<double> _dailySteps = [];
  final List<DateTime> _chargeTimes = [];
  int _smsLoanCount = 0;

  void startCollection() {
    _accelSubscription = accelerometerEventStream().listen(_onAccelerometerEvent);
    _battery.onBatteryStateChanged.listen(_onBatteryStateChanged);
    _listenToSMS();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Simple step detection using magnitude threshold
    double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (magnitude > 12.0) { // Threshold for step detection
      _dailySteps.add(magnitude);
    }
  }

  void _onBatteryStateChanged(BatteryState state) {
    if (state == BatteryState.charging) {
      _chargeTimes.add(DateTime.now());
    }
  }

  void _listenToSMS() async {
    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.DATE, SmsColumn.BODY],
      filter: SmsFilter.where(SmsColumn.DATE)
          .greaterThan(DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch.toString()),
    );

    _smsLoanCount = messages.where((msg) => 
      msg.body?.toLowerCase().contains('inguzanyo') == true ||
      msg.body?.toLowerCase().contains('kubaka') == true ||
      msg.body?.toLowerCase().contains('tala') == true ||
      msg.body?.toLowerCase().contains('debt') == true
    ).length;
  }

  DailyData getDailyData() {
    double stepsMean = _dailySteps.isEmpty ? 0 : _dailySteps.reduce((a, b) => a + b) / _dailySteps.length;
    double stepsStd = _calculateStandardDeviation(_dailySteps);
    
    int nightCharges = _chargeTimes.where((time) => 
      time.hour >= 18 || time.hour <= 6
    ).length;
    double chargeNightPct = _chargeTimes.isEmpty ? 0 : nightCharges / _chargeTimes.length;

    return DailyData(
      date: DateTime.now(),
      stepsMean: stepsMean,
      stepsStd: stepsStd,
      idlePeriods: _dailySteps.length < 100 ? 1 : 0, // Simple idle detection
      chargeNightPct: chargeNightPct,
      chargeCycles: _chargeTimes.length,
      smsLoanCount: _smsLoanCount,
    );
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = values.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  void resetDaily() {
    _dailySteps.clear();
    _chargeTimes.clear();
    _smsLoanCount = 0;
  }

  void dispose() {
    _accelSubscription?.cancel();
  }
}
