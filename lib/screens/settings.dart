// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: const [
            AppHeader(
              title: 'Settings',
              subtitle: 'Configure your preferences',
              icon: Icons.settings,
            ),
            Expanded(
              child: Center(
                child: Text('Settings screen (coming soon)', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
