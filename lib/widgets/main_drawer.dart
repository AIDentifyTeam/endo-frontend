import 'package:flutter/material.dart';
import 'package:endo_frontend/services/api_service.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String? doctorLastName;
  String? profileImageUrl;
  final String baseUrl = 'http://localhost:8000'; // change for deployment

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    final profile = await ApiService().getDoctorProfile();
    if (profile != null && mounted) {
      final rawUrl = profile['profile_image'];
      setState(() {
        doctorLastName = profile['last_name'];
        if (rawUrl != null && rawUrl.toString().isNotEmpty) {
          profileImageUrl = rawUrl.toString().startsWith('http')
              ? rawUrl
              : '$baseUrl$rawUrl';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// Drawer Header with dynamic data
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
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: (profileImageUrl != null)
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: (profileImageUrl == null)
                        ? Icon(Icons.person, color: Color(0xFF4F46E5))
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (doctorLastName != null)
                        ? 'Dr. $doctorLastName'
                        : 'Dr.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
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
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => Navigator.pushReplacementNamed(context, '/notifications'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
            ),

            const Divider(),

            /// Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                try {
                  await ApiService().logout(); // Send refresh token to backend
                } catch (e) {
                  debugPrint('Logout error: $e');
                  // Proceed anyway
                }

                await ApiService().clearTokens(); // delete access & refresh from secure storage

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
