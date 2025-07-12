import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'New Case Review',
      description: 'You have 2 new patient cases to review.',
      type: 'New Case Review',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationItem(
      id: '2',
      title: 'System Update',
      description: 'EndoDiag Pro updated to version 1.2.',
      type: 'System Update',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Reminder',
      description: 'Submit report for patient John D.',
      type: 'Reminder',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  Icon _getIconForType(String type) {
    switch (type) {
      case 'New Case Review':
        return const Icon(Icons.assignment_turned_in, color: Colors.blue);
      case 'System Update':
        return const Icon(Icons.system_update_alt, color: Colors.green);
      case 'Reminder':
        return const Icon(Icons.alarm, color: Colors.orange);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Notifications',
              subtitle: 'Latest alerts and updates',
              icon: Icons.notifications,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final n = _notifications[index];

                  return GestureDetector(
                    onTap: () {
                      if (!n.isRead) {
                        setState(() {
                          n.isRead = true;
                        });
                      }
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getIconForType(n.type),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        n.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (!n.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    n.description,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('yyyy-MM-dd – HH:mm').format(n.timestamp),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
