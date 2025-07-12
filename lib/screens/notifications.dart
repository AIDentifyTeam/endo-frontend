// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: const [
            AppHeader(
              title: 'Notifications',
              subtitle: 'Check latest alerts and updates',
              icon: Icons.notifications,
            ),
            Expanded(
              child: Center(
                child: Text('Notifications screen (coming soon)', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
