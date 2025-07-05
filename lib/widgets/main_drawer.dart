// lib/widgets/main_drawer.dart
import 'package:flutter/material.dart';
import '../routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // 👈 Change the background to pure white
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4F46E5)),
                  ),
                  SizedBox(height: 8),
                  Text('Dr. Smith', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Endodontist', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('New Patient'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/new_patient');
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Patient History'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/patient_history');
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Research Papers'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/research_papers');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // TODO: Add logout logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
