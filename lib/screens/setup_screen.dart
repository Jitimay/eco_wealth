import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/user_profile.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  SetupScreenState createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _goatsController = TextEditingController(text: '0');
  final _chickensController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EchoWealth Setup'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Murakaza neza! / Welcome!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Izina ryawe / Your Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _villageController,
                decoration: InputDecoration(
                  labelText: 'Umudugudu / Village',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _goatsController,
                      decoration: InputDecoration(
                        labelText: 'Inka / Goats',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _chickensController,
                      decoration: InputDecoration(
                        labelText: 'Inkoko / Chickens',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Tangira / Start',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() == true) {
      final profile = UserProfile(
        name: _nameController.text,
        village: _villageController.text,
        goats: int.tryParse(_goatsController.text) ?? 0,
        chickens: int.tryParse(_chickensController.text) ?? 0,
        createdAt: DateTime.now(),
      );
      
      context.read<AppBloc>().add(CreateUserProfile(profile));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _goatsController.dispose();
    _chickensController.dispose();
    super.dispose();
  }
}
