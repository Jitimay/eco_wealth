import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  int _goats = 0;
  int _chickens = 0;
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserProfile profile) {
    _nameController.text = profile.name;
    _villageController.text = profile.village;
    _goats = profile.goats;
    _chickens = profile.chickens;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state is! AppReady) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!_isEditing) {
          _initializeControllers(state.profile);
        }

        return Container(
          color: Colors.grey[50],
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                          ),
                          Text(
                            'Umwirondoro wawe',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _isEditing = !_isEditing),
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildProfileHeader(context, state),
                  const SizedBox(height: 24),

                  if (_isEditing) ...[
                    _buildEditForm(context, state),
                  ] else ...[
                    _buildProfileInfo(context, state),
                    const SizedBox(height: 24),
                    _buildStats(context, state),
                    const SizedBox(height: 24),
                    _buildSettings(context, state),
                  ],

                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppReady state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            state.profile.village,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                  '${state.profile.goats}', 'Ihene / Goats', Icons.pets),
              _buildHeaderStat(
                  '${state.profile.chickens}', 'Inkoko / Chickens', Icons.egg),
              _buildHeaderStat(
                  '${_calculateDaysActive(state.profile.createdAt)}',
                  'Iminsi / Days',
                  Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, AppReady state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Name field
        _buildTextField(
          controller: _nameController,
          label: 'Amazina yawe / Your Name',
          icon: Icons.person,
        ),
        const SizedBox(height: 16),

        // Village field
        _buildTextField(
          controller: _villageController,
          label: 'Umudugudu / Village',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 24),

        // Assets section
        Text(
          'Umutungo wawe / Your Assets',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),

        _buildAssetCounter(
          title: 'Ihene / Goats',
          icon: Icons.pets,
          value: _goats,
          onChanged: (value) => setState(() => _goats = value),
        ),
        const SizedBox(height: 16),

        _buildAssetCounter(
          title: 'Inkoko / Chickens',
          icon: Icons.egg,
          value: _chickens,
          onChanged: (value) => setState(() => _chickens = value),
        ),

        const SizedBox(height: 32),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveProfile(context, state),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bika / Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, AppReady state) {
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
          Text(
            'Profile Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Amakuru y\'umwirondoro',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name / Amazina', state.profile.name, Icons.person),
          _buildInfoRow(
              'Village / Umudugudu', state.profile.village, Icons.location_on),
          _buildInfoRow('Goats / Ihene', '${state.profile.goats}', Icons.pets),
          _buildInfoRow(
              'Chickens / Inkoko', '${state.profile.chickens}', Icons.egg),
          _buildInfoRow('Member Since / Kuva',
              _formatDate(state.profile.createdAt), Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AppReady state) {
    final totalPredictions = state.predictions.length;
    final avgRisk = state.predictions.isEmpty
        ? 0.0
        : state.predictions.map((p) => p.riskScore).reduce((a, b) => a + b) /
            state.predictions.length;
    final dataPoints = state.dailyData.length;

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
          Text(
            'Your Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Imibare yawe',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Risk Assessments',
                  'Isuzuma ry\'umuvunyi',
                  totalPredictions.toString(),
                  Icons.analytics,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Average Risk',
                  'Umuvunyi rusange',
                  '${avgRisk.toInt()}%',
                  Icons.trending_up,
                  _getRiskColor(avgRisk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Data Points',
                  'Amakuru akusanyijwe',
                  dataPoints.toString(),
                  Icons.data_usage,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Days Active',
                  'Iminsi ukoreye',
                  _calculateDaysActive(state.profile.createdAt).toString(),
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, AppReady state) {
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
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Amategeko',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language / Ururimi',
            subtitle: state.isKirundiEnabled ? 'Kirundi' : 'English',
            trailing: Switch(
              value: state.isKirundiEnabled,
              onChanged: (_) => context.read<AppBloc>().add(ToggleLanguage()),
              activeColor: Colors.green[700],
            ),
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Voice Alerts / Amajwi',
            subtitle: 'Risk warnings in Kirundi',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeColor: Colors.green[700],
            ),
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy / Ubwoba',
            subtitle: 'All data stays on device',
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const Divider(),
          _buildSettingItem(
            icon: Icons.info,
            title: 'About EchoWealth',
            subtitle: 'Version 1.0.0 • Arm AI Challenge 2025',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildAssetCounter({
    required String title,
    required IconData icon,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.green[700],
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.green[700],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String subtitle, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.green[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _saveProfile(BuildContext context, AppReady state) {
    if (_nameController.text.isNotEmpty && _villageController.text.isNotEmpty) {
      final updatedProfile = UserProfile(
        name: _nameController.text,
        village: _villageController.text,
        goats: _goats,
        chickens: _chickens,
        createdAt: state.profile.createdAt,
      );

      context.read<AppBloc>().add(CreateUserProfile(updatedProfile));
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green[700],
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About EchoWealth'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'EchoWealth - On-device poverty risk prediction for Burundian farmers'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• 100% on-device processing'),
            Text('• Privacy-first design'),
            Text('• Kirundi language support'),
            Text('• Arm NPU optimization'),
            SizedBox(height: 16),
            Text('Built for Arm AI Developer Challenge 2025'),
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

  Color _getRiskColor(double score) {
    if (score < 30) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  int _calculateDaysActive(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
