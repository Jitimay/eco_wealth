import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/app_bloc.dart';
import '../models/risk_prediction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('EchoWealth'),
              backgroundColor: Colors.green[700],
              bottom: TabBar(
                tabs: [
                  Tab(text: 'Umuvunyi / Risk'),
                  Tab(text: 'Imibare / Stats'),
                  Tab(text: 'Amategeko / Settings'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildRiskTab(context, state),
                _buildStatsTab(context, state),
                _buildSettingsTab(context, state),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                context.read<AppBloc>().add(SimulateWalk());
              },
              backgroundColor: Colors.green[700],
              tooltip: 'Demo Walk',
              child: const Icon(Icons.directions_walk, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskTab(BuildContext context, AppReady state) {
    final latestPrediction = state.predictions.isNotEmpty 
        ? state.predictions.last 
        : null;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Muraho, ${state.profile.name}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  
                  if (latestPrediction != null) ...[
                    CircularProgressIndicator(
                      value: latestPrediction.riskScore / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getRiskColor(latestPrediction.riskScore),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${latestPrediction.riskScore.toInt()}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _getRiskColor(latestPrediction.riskScore),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${latestPrediction.riskCategory} / ${latestPrediction.riskCategoryKirundi}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 16),
                    
                    if (latestPrediction.riskScore > 70) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 32),
                            SizedBox(height: 8),
                            Text(
                              latestPrediction.advice,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _showPreventionDialog(context, latestPrediction),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                              ),
                              child: Text('Kuraguza / Prevent', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          latestPrediction.advice,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'Tegereza iminsi 7 kugira ngo tubashe gusuzuma umuvunyi',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Wait 7 days for risk assessment',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (state.predictions.length > 1) ...[
            SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Umuvunyi mu gihe / Risk Over Time',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: state.predictions.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), entry.value.riskScore);
                                }).toList(),
                                isCurved: true,
                                color: Colors.green[700],
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context, AppReady state) {
    final latestPrediction = state.predictions.isNotEmpty ? state.predictions.last : null;
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance / Imikorere',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  
                  if (latestPrediction != null) ...[
                    _buildStatRow('Inference Time', '${latestPrediction.inferenceTimeMs}ms'),
                    _buildStatRow('NPU Acceleration', 'Enabled'),
                    _buildStatRow('Power Usage', '~0.02W'),
                    _buildStatRow('Model Size', '1.2 MB'),
                  ] else ...[
                    Text('No performance data yet'),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Collection / Gukusanya Amakuru',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 16),
                  
                  _buildStatRow('Days Collected', '${state.dailyData.length}'),
                  _buildStatRow('Predictions Made', '${state.predictions.length}'),
                  _buildStatRow('Privacy Mode', 'On-Device Only'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context, AppReady state) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              title: Text('Language / Ururimi'),
              subtitle: Text(state.isKirundiEnabled ? 'Kirundi' : 'English'),
              trailing: Switch(
                value: state.isKirundiEnabled,
                onChanged: (_) => context.read<AppBloc>().add(ToggleLanguage()),
              ),
            ),
          ),
          
          Card(
            child: ListTile(
              title: Text('Profile / Umwirondoro'),
              subtitle: Text('${state.profile.name} - ${state.profile.village}'),
              trailing: Icon(Icons.person),
            ),
          ),
          
          Card(
            child: ListTile(
              title: Text('Assets / Umutungo'),
              subtitle: Text('${state.profile.goats} goats, ${state.profile.chickens} chickens'),
              trailing: Icon(Icons.pets),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getRiskColor(double score) {
    if (score < 30) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  void _showPreventionDialog(BuildContext context, RiskPrediction prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prevention Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(prediction.advice),
            SizedBox(height: 16),
            Text('Additional suggestions:'),
            Text('• Visit market more frequently'),
            Text('• Reduce unnecessary expenses'),
            Text('• Consider selling assets if needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
