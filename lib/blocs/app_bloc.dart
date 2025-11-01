import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/daily_data.dart';
import '../models/risk_prediction.dart';
import '../services/sensor_service.dart';
import '../services/ml_service.dart';
import '../services/voice_service.dart';

// Events
abstract class AppEvent {}

class InitializeApp extends AppEvent {}
class CreateUserProfile extends AppEvent {
  final UserProfile profile;
  CreateUserProfile(this.profile);
}
class CollectDailyData extends AppEvent {}
class RunRiskPrediction extends AppEvent {}
class ToggleLanguage extends AppEvent {}
class SimulateWalk extends AppEvent {}

// States
abstract class AppState {}

class AppInitial extends AppState {}
class AppLoading extends AppState {}
class SetupRequired extends AppState {}
class AppReady extends AppState {
  final UserProfile profile;
  final List<DailyData> dailyData;
  final List<RiskPrediction> predictions;
  final bool isKirundiEnabled;

  AppReady({
    required this.profile,
    required this.dailyData,
    required this.predictions,
    required this.isKirundiEnabled,
  });
}
class AppError extends AppState {
  final String message;
  AppError(this.message);
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final SensorService _sensorService = SensorService();
  final MLService _mlService = MLService();
  final VoiceService _voiceService = VoiceService();

  late Box<UserProfile> _profileBox;
  late Box<DailyData> _dailyDataBox;
  late Box<RiskPrediction> _predictionsBox;

  AppBloc() : super(AppInitial()) {
    on<InitializeApp>(_onInitializeApp);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<CollectDailyData>(_onCollectDailyData);
    on<RunRiskPrediction>(_onRunRiskPrediction);
    on<ToggleLanguage>(_onToggleLanguage);
    on<SimulateWalk>(_onSimulateWalk);
  }

  Future<void> _onInitializeApp(InitializeApp event, Emitter<AppState> emit) async {
    try {
      emit(AppLoading());
      
      // Initialize Hive
      await Hive.initFlutter();
      Hive.registerAdapter(UserProfileAdapter());
      Hive.registerAdapter(DailyDataAdapter());
      Hive.registerAdapter(RiskPredictionAdapter());
      
      _profileBox = await Hive.openBox<UserProfile>('profiles');
      _dailyDataBox = await Hive.openBox<DailyData>('daily_data');
      _predictionsBox = await Hive.openBox<RiskPrediction>('predictions');
      
      // Initialize services
      await _mlService.initialize();
      await _voiceService.initialize();
      _sensorService.startCollection();
      
      // Check if user profile exists
      final profile = _profileBox.get('current');
      if (profile == null) {
        emit(SetupRequired());
      } else {
        final dailyData = _dailyDataBox.values.toList();
        final predictions = _predictionsBox.values.toList();
        
        emit(AppReady(
          profile: profile,
          dailyData: dailyData,
          predictions: predictions,
          isKirundiEnabled: _voiceService.isKirundiEnabled,
        ));
      }
    } catch (e) {
      emit(AppError('Initialization failed: $e'));
    }
  }

  Future<void> _onCreateUserProfile(CreateUserProfile event, Emitter<AppState> emit) async {
    try {
      await _profileBox.put('current', event.profile);
      
      emit(AppReady(
        profile: event.profile,
        dailyData: [],
        predictions: [],
        isKirundiEnabled: _voiceService.isKirundiEnabled,
      ));
    } catch (e) {
      emit(AppError('Failed to create profile: $e'));
    }
  }

  Future<void> _onCollectDailyData(CollectDailyData event, Emitter<AppState> emit) async {
    if (state is! AppReady) return;
    
    try {
      final currentState = state as AppReady;
      final dailyData = _sensorService.getDailyData();
      
      await _dailyDataBox.add(dailyData);
      _sensorService.resetDaily();
      
      final updatedDailyData = _dailyDataBox.values.toList();
      
      emit(AppReady(
        profile: currentState.profile,
        dailyData: updatedDailyData,
        predictions: currentState.predictions,
        isKirundiEnabled: currentState.isKirundiEnabled,
      ));
    } catch (e) {
      emit(AppError('Failed to collect data: $e'));
    }
  }

  Future<void> _onRunRiskPrediction(RunRiskPrediction event, Emitter<AppState> emit) async {
    if (state is! AppReady) return;
    
    try {
      final currentState = state as AppReady;
      final weekData = currentState.dailyData.take(7).toList();
      
      if (weekData.length >= 7) {
        final prediction = await _mlService.predictRisk(weekData);
        await _predictionsBox.add(prediction);
        
        // Trigger alert if high risk
        if (prediction.riskScore > 70) {
          await _voiceService.speakRiskAlert(prediction.riskScore, prediction.advice);
        }
        
        final updatedPredictions = _predictionsBox.values.toList();
        
        emit(AppReady(
          profile: currentState.profile,
          dailyData: currentState.dailyData,
          predictions: updatedPredictions,
          isKirundiEnabled: currentState.isKirundiEnabled,
        ));
      }
    } catch (e) {
      emit(AppError('Prediction failed: $e'));
    }
  }

  Future<void> _onToggleLanguage(ToggleLanguage event, Emitter<AppState> emit) async {
    if (state is! AppReady) return;
    
    _voiceService.toggleLanguage();
    final currentState = state as AppReady;
    
    emit(AppReady(
      profile: currentState.profile,
      dailyData: currentState.dailyData,
      predictions: currentState.predictions,
      isKirundiEnabled: _voiceService.isKirundiEnabled,
    ));
  }

  Future<void> _onSimulateWalk(SimulateWalk event, Emitter<AppState> emit) async {
    // Demo mode: simulate increased activity
    final mockData = DailyData(
      date: DateTime.now(),
      stepsMean: 8000 + (DateTime.now().millisecond % 2000),
      stepsStd: 1500,
      idlePeriods: 0,
      chargeNightPct: 0.3,
      chargeCycles: 2,
      smsLoanCount: 1,
    );
    
    await _dailyDataBox.add(mockData);
    add(RunRiskPrediction());
  }

  @override
  Future<void> close() {
    _sensorService.dispose();
    _mlService.dispose();
    _voiceService.dispose();
    return super.close();
  }
}
