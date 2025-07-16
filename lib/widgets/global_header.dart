import 'package:flutter/material.dart';
import 'package:endo_frontend/services/api_service.dart';

class AppHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? doctorLastName;
  String? profileImageUrl;
  final String baseUrl = 'http://localhost:8000'; // update if deployed

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  Future<void> _loadDoctorInfo() async {
    final profile = await ApiService().getDoctorProfile(); // avoid stale cache
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Drawer Button
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF2563EB)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          const SizedBox(width: 8),

          /// Gradient Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 12),

          /// Title + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          /// User Info with Profile Picture
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  backgroundColor: const Color(0xFF2563EB),
                  child: (profileImageUrl == null)
                      ? Text(
                          (doctorLastName != null && doctorLastName!.isNotEmpty)
                              ? doctorLastName![0].toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  (doctorLastName != null && doctorLastName!.isNotEmpty)
                      ? 'Dr. $doctorLastName'
                      : 'Dr.',
                  style: const TextStyle(
                    fontSize: 14,
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
}
