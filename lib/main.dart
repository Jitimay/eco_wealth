import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'blocs/app_bloc.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permissions
  await _requestPermissions();

  runApp(EchoWealthApp());
}

Future<void> _requestPermissions() async {
  await [
    Permission.sensors,
    Permission.sms,
    Permission.phone,
  ].request();
}

class EchoWealthApp extends StatelessWidget {
  const EchoWealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc()..add(InitializeApp()),
      child: MaterialApp(
        title: 'EchoWealth',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppInitial || state is AppLoading) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Gutegura EchoWealth...'),
                      Text('Initializing EchoWealth...'),
                    ],
                  ),
                ),
              );
            }

            if (state is SetupRequired) {
              return OnboardingScreen();
            }

            if (state is AppReady) {
              return MainNavigationScreen();
            }

            if (state is AppError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<AppBloc>().add(InitializeApp()),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}
