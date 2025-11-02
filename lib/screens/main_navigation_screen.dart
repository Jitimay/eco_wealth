import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import 'home_dashboard_screen.dart';
import 'risk_history_screen.dart';
import 'prevent_action_screen.dart';
import 'benchmarks_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              HomeDashboardPage(),
              RiskHistoryPage(),
              PreventActionPage(),
              BenchmarksPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        index: 0,
                        icon: Icons.home,
                        label: 'Home',
                        labelKirundi: 'Ahabanza',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 1,
                        icon: Icons.history,
                        label: 'History',
                        labelKirundi: 'Amateka',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 2,
                        icon: Icons.shield,
                        label: 'Prevent',
                        labelKirundi: 'Kuraguza',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 3,
                        icon: Icons.speed,
                        label: 'Benchmarks',
                        labelKirundi: 'Imikorere',
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        index: 4,
                        icon: Icons.person,
                        label: 'Profile',
                        labelKirundi: 'Umwirondoro',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    // Simulate high risk for demo
                    context.read<AppBloc>().add(SimulateWalk());
                  },
                  backgroundColor: Colors.red[600],
                  child: const Icon(Icons.warning, color: Colors.white),
                  tooltip: 'Demo High Risk',
                )
              : null,
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String labelKirundi,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Colors.green[700] : Colors.grey[500];

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            if (isSelected) ...[
              Text(
                labelKirundi,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 7,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Wrapper classes to remove AppBar and make them work as pages
class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 24),
                _buildRiskCircle(context, state),
                const SizedBox(height: 32),
                _buildQuickActions(context, state),
                const SizedBox(height: 24),
                _buildRecentActivity(context, state),
                const SizedBox(height: 80), // Space for bottom nav
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppReady state) {
    return Row(
      children: [
        // Goat icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.pets,
            color: Colors.green[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Text(
            '${state.profile.name} · ${state.profile.village}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
        ),

        // Settings icon
        IconButton(
          onPressed: () {
            // Navigate to profile page
            final mainNavState =
                context.findAncestorStateOfType<_MainNavigationScreenState>();
            mainNavState?._onTabTapped(4);
          },
          icon: Icon(
            Icons.settings,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCircle(BuildContext context, AppReady state) {
    final latestPrediction =
        state.predictions.isNotEmpty ? state.predictions.last : null;
    final riskScore =
        latestPrediction?.riskScore ?? 81.0; // Default to high risk for demo
    final riskCategory = riskScore > 70
        ? 'HIGH — ACT NOW'
        : latestPrediction?.riskCategory ?? 'Unknown';

    // Trigger vibration and voice for high risk
    if (riskScore > 70) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200),
            () => HapticFeedback.heavyImpact());
        Future.delayed(const Duration(milliseconds: 400),
            () => HapticFeedback.heavyImpact());
      });
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: riskScore > 70
              ? [Colors.red[50]!, Colors.red[100]!]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (riskScore > 70 ? Colors.red : Colors.black).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'RISK',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 16),

          // Risk circle with pulsing animation for high risk
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing outer ring for high risk
                if (riskScore > 70) ...[
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ],

                // Main risk circle
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: riskScore / 100,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getRiskColor(riskScore),
                    ),
                  ),
                ),

                // Center content
                Column(
                  children: [
                    Text(
                      '${riskScore.toInt()}%',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRiskColor(riskScore),
                            fontSize: 48,
                          ),
                    ),
                    Text(
                      riskCategory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: riskScore > 70
                                ? Colors.red[800]
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Voice and vibration indicators for high risk
          if (riskScore > 70) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.vibration,
                    color: Colors.red[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.volume_up,
                    color: Colors.red[700],
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kirundi voice message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                '"Umuvunyi: ${riskScore.toInt()}%. Gura inka imwe..."',
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // PREVENT NOW button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to prevent action page
                  final mainNavState = context
                      .findAncestorStateOfType<_MainNavigationScreenState>();
                  mainNavState
                      ?._onTabTapped(2); // Navigate to prevent action tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'PREVENT NOW',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Low/medium risk display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      latestPrediction?.advice ??
                          'Komeza gutyo, uri ku nzira nziza',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibikorwa / Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.pets,
                title: 'Sell Goat',
                subtitle: 'Gura ihene',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.store,
                title: 'Visit Market',
                subtitle: 'Jya ku isoko',
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color[700],
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibikorwa bya vuba / Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        const SizedBox(height: 16),
        if (state.predictions.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.timeline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Nta bikorwa biri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...state.predictions
              .take(3)
              .map((prediction) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getRiskColor(prediction.riskScore)
                                .withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getRiskIcon(prediction.riskScore),
                            color: _getRiskColor(prediction.riskScore),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk Assessment: ${prediction.riskScore.toInt()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(prediction.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${prediction.inferenceTimeMs}ms',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ],
    );
  }

  Color _getRiskColor(double score) {
    if (score < 30) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  IconData _getRiskIcon(double score) {
    if (score < 30) return Icons.check_circle;
    if (score < 70) return Icons.warning;
    return Icons.error;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Mwaramutse / Good morning';
    if (hour < 17) return 'Mwiriwe / Good afternoon';
    return 'Muramuke / Good evening';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Page wrappers for other screens
class RiskHistoryPage extends StatelessWidget {
  const RiskHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RiskHistoryScreen();
  }
}

class PreventActionPage extends StatelessWidget {
  const PreventActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PreventActionScreen();
  }
}

class BenchmarksPage extends StatelessWidget {
  const BenchmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BenchmarksScreen();
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
