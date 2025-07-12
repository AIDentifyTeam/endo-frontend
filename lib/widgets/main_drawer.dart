import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// Drawer Header
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
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF4F46E5)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dr. Smith',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Endodontist',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            /// Navigation Items
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('New Patient'),
              onTap: () => Navigator.pushReplacementNamed(context, '/new_patient'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Patient History'),
              onTap: () => Navigator.pushReplacementNamed(context, '/patient_history'),
            ),
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Research Papers'),
              onTap: () => Navigator.pushReplacementNamed(context, '/research_papers'),
            ),

            const Divider(),

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/notifications');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
            const Divider(),

            /// Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
// This widget can be used in your main app or any screen that requires a drawer.