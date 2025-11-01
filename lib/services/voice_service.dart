import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isKirundiEnabled = true;

  Future<void> initialize() async {
    await _tts.setLanguage('en-US'); // Fallback to English
    await _tts.setSpeechRate(0.8);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speakRiskAlert(double riskScore, String advice) async {
    String message;
    
    if (_isKirundiEnabled) {
      message = 'Umuvunyi uzagabanuka ${riskScore.toInt()}%. $advice';
    } else {
      message = 'Risk level is ${riskScore.toInt()}%. $advice';
    }
    
    await _tts.speak(message);
  }

  Future<void> speakAdvice(String advice) async {
    await _tts.speak(advice);
  }

  void toggleLanguage() {
    _isKirundiEnabled = !_isKirundiEnabled;
  }

  bool get isKirundiEnabled => _isKirundiEnabled;

  void dispose() {
    _tts.stop();
  }
}
