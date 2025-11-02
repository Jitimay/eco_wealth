import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';

class PreventActionScreen extends StatelessWidget {
  const PreventActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return const Center(child: CircularProgressIndicator());
        }

        final latestPrediction = state.predictions.isNotEmpty ? state.predictions.last : null;
        final riskScore = latestPrediction?.riskScore ?? 0.0;

        return Container(
          color: Colors.grey[50],
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'Prevent Action',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    'Kuraguza ubukene',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildRiskStatus(context, riskScore),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, state),
                  const SizedBox(height: 24),
                  _buildDetailedActions(context, riskScore),
                  const SizedBox(height: 24),
                  _buildEmergencyContact(context),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRiskStatus(BuildContext context, double riskScore) {
    final isHighRisk = riskScore > 70;
    final isMediumRisk = riskScore > 40 && riskScore <= 70;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHighRisk 
              ? [Colors.red[400]!, Colors.red[600]!]
              : isMediumRisk
                  ? [Colors.orange[400]!, Colors.orange[600]!]
                  : [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isHighRisk ? Colors.red : isMediumRisk ? Colors.orange : Colors.green)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isHighRisk ? Icons.warning : isMediumRisk ? Icons.info : Icons.check_circle,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isHighRisk 
                ? 'Umuvunyi mwinshi!'
                : isMediumRisk 
                    ? 'Umuvunyi hagati'
                    : 'Umuvunyi muke',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            isHighRisk 
                ? 'High Risk Alert!'
                : isMediumRisk 
                    ? 'Medium Risk'
                    : 'Low Risk',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${riskScore.toInt()}% Risk Level',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibikorwa byo kwihutira / Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.pets,
                title: 'Sell Goat',
                subtitle: 'Gura ihene',
                color: Colors.orange,
                onTap: () => _showActionDialog(context, 'Sell Goat', 'Gura ihene imwe kugira ngo ugabanye umuvunyi'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.store,
                title: 'Visit Market',
                subtitle: 'Jya ku isoko',
                color: Colors.blue,
                onTap: () => _showActionDialog(context, 'Visit Market', 'Ongera genda ku isoko kugira ngo ushake amahirwe'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.agriculture,
                title: 'Plant Beans',
                subtitle: 'Tera ibinyomoro',
                color: Colors.green,
                onTap: () => _showActionDialog(context, 'Plant Beans', 'Tera ibinyomoro kugira ngo ufite ibiryo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.savings,
                title: 'Save Money',
                subtitle: 'Bika amafaranga',
                color: Colors.purple,
                onTap: () => _showActionDialog(context, 'Save Money', 'Bika amafaranga kugira ngo ufite ubwoba'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedActions(BuildContext context, double riskScore) {
    final actions = _getDetailedActions(riskScore);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ibikorwa birambuye / Detailed Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...actions.map((action) => _buildDetailedActionItem(context, action)).toList(),
      ],
    );
  }

  Widget _buildDetailedActionItem(BuildContext context, Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'],
                  color: action['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      action['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: action['priority'] == 'High' 
                      ? Colors.red[50] 
                      : action['priority'] == 'Medium'
                          ? Colors.orange[50]
                          : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  action['priority'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: action['priority'] == 'High' 
                        ? Colors.red[700] 
                        : action['priority'] == 'Medium'
                            ? Colors.orange[700]
                            : Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            action['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                'Timeline: ${action['timeline']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showActionDialog(context, action['title'], action['description']),
                child: const Text('Learn More'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emergency,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ubufasha bw\'ihutirwa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            'Emergency Support',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Niba ufite ikibazo gikomeye, hamagara umunyamabanga w\'umudugudu cyangwa se ubufasha bw\'abakunzi.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'If you have a serious problem, contact your village secretary or community support.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showEmergencyDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Contact Support',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDetailedActions(double riskScore) {
    if (riskScore > 70) {
      return [
        {
          'icon': Icons.pets,
          'title': 'Sell Livestock',
          'subtitle': 'Gura inyamaswa',
          'description': 'Consider selling one goat or several chickens to generate immediate income. This can help cover essential expenses and reduce financial pressure.',
          'timeline': 'Within 1 week',
          'priority': 'High',
          'color': Colors.red,
        },
        {
          'icon': Icons.work,
          'title': 'Find Additional Work',
          'subtitle': 'Shakisha akazi k\'inyongera',
          'description': 'Look for temporary work opportunities in your community such as farm labor, construction, or small trading activities.',
          'timeline': 'Immediate',
          'priority': 'High',
          'color': Colors.orange,
        },
        {
          'icon': Icons.cut,
          'title': 'Reduce Expenses',
          'subtitle': 'Gabanya amafaranga ukoresha',
          'description': 'Cut non-essential spending and focus only on basic needs like food, shelter, and healthcare.',
          'timeline': 'Immediate',
          'priority': 'High',
          'color': Colors.purple,
        },
      ];
    } else if (riskScore > 40) {
      return [
        {
          'icon': Icons.agriculture,
          'title': 'Diversify Crops',
          'subtitle': 'Tera ibinyomoro bitandukanye',
          'description': 'Plant different types of crops to ensure food security and potential income from surplus harvest.',
          'timeline': 'Next planting season',
          'priority': 'Medium',
          'color': Colors.green,
        },
        {
          'icon': Icons.store,
          'title': 'Market Activities',
          'subtitle': 'Ibikorwa by\'isoko',
          'description': 'Increase your market visits to find better prices for your products and discover new opportunities.',
          'timeline': '2-3 weeks',
          'priority': 'Medium',
          'color': Colors.blue,
        },
        {
          'icon': Icons.group,
          'title': 'Join Cooperative',
          'subtitle': 'Injira mu koperative',
          'description': 'Consider joining or forming a cooperative with other farmers to share resources and reduce costs.',
          'timeline': '1 month',
          'priority': 'Medium',
          'color': Colors.teal,
        },
      ];
    } else {
      return [
        {
          'icon': Icons.savings,
          'title': 'Build Savings',
          'subtitle': 'Bika amafaranga',
          'description': 'Continue saving money regularly to build a financial buffer for future challenges.',
          'timeline': 'Ongoing',
          'priority': 'Low',
          'color': Colors.green,
        },
        {
          'icon': Icons.school,
          'title': 'Learn New Skills',
          'subtitle': 'Wige ubuhanga bushya',
          'description': 'Invest time in learning new farming techniques or other skills that could increase your income.',
          'timeline': '2-3 months',
          'priority': 'Low',
          'color': Colors.indigo,
        },
      ];
    }
  }

  void _showActionDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Action "$title" noted. Good luck!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Got it', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Emergency Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency contacts:'),
            SizedBox(height: 8),
            Text('• Village Secretary: Contact your local leader'),
            Text('• Community Health Worker: For health emergencies'),
            Text('• Agricultural Extension Officer: For farming advice'),
            Text('• Local Cooperative: For financial support'),
            SizedBox(height: 16),
            Text(
              'Remember: This app provides guidance, but human support is always available in your community.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}