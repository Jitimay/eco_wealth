import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  int _goats = 3; // Default to match spec
  int _chickens = 12; // Default to match spec

  @override
  void initState() {
    super.initState();
    // Set default values to match the spec
    _nameController.text = 'Marie';
    _villageController.text = 'Gitega';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: _buildWelcomePage(),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Goat Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets, // Goat icon
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Welcome text
          Text(
            'Welcome, Farmer!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Murakaza neza, Umuhinzi!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Name field
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Marie',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.green[700]!, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Village dropdown
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Village:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _villageController.text.isEmpty
                      ? null
                      : _villageController.text,
                  decoration: InputDecoration(
                    hintText: 'Gitega',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.green[700]!, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Gitega', child: Text('Gitega')),
                    DropdownMenuItem(
                        value: 'Bujumbura', child: Text('Bujumbura')),
                    DropdownMenuItem(value: 'Ngozi', child: Text('Ngozi')),
                    DropdownMenuItem(value: 'Kayanza', child: Text('Kayanza')),
                    DropdownMenuItem(
                        value: 'Cibitoke', child: Text('Cibitoke')),
                    DropdownMenuItem(value: 'Bubanza', child: Text('Bubanza')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _villageController.text = value;
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Assets row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goats: $_goats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _goats > 0
                              ? () => setState(() => _goats--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.green[700],
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            _goats.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _goats++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green[700],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chickens: $_chickens',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _chickens > 0
                              ? () => setState(() => _chickens--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.green[700],
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            _chickens.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _chickens++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green[700],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Permissions checkboxes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Allow sensors',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Allow SMS count (no reading)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // START PROTECTING button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.isNotEmpty &&
                      _villageController.text.isNotEmpty
                  ? () => _completeOnboarding()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'START PROTECTING',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeOnboarding() {
    if (_nameController.text.isEmpty) {
      _nameController.text = 'Marie'; // Default name
    }
    if (_villageController.text.isEmpty) {
      _villageController.text = 'Gitega'; // Default village
    }
    if (_goats == 0) {
      _goats = 3; // Default goats
    }
    if (_chickens == 0) {
      _chickens = 12; // Default chickens
    }

    final profile = UserProfile(
      name: _nameController.text,
      village: _villageController.text,
      goats: _goats,
      chickens: _chickens,
      createdAt: DateTime.now(),
    );

    context.read<AppBloc>().add(CreateUserProfile(profile));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }
}
