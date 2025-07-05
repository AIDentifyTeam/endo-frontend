// lib/widgets/main_drawer.dart
import 'package:flutter/material.dart';
import '../routes.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Color(0xFF2563EB)),
                ),
                SizedBox(height: 12),
                Text(
                  'Dr. Smith',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Endodontist', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Navigator.pushNamed(context, Routes.dashboard),
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('New Patient'),
            onTap: () => Navigator.pushNamed(context, Routes.newPatient),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Patient History'),
            onTap: () => Navigator.pushNamed(context, Routes.patientHistory),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Research Papers'),
            onTap: () => Navigator.pushNamed(context, Routes.research),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () => Navigator.pushNamed(context, Routes.login),
          ),
        ],
      ),
    );
  }
}
