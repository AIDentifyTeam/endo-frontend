import 'package:flutter/material.dart';
import 'package:endo_frontend/widgets/global_header.dart';
import 'package:endo_frontend/widgets/main_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _firstNameController = TextEditingController(text: 'John');
  final TextEditingController _lastNameController = TextEditingController(text: 'Doe');
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _deleteConfirmController = TextEditingController();

  void _changePassword() {
    // Mocked password change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed (mocked).')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚠️ All data will be permanently deleted and cannot be recovered.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To confirm account deletion, type: DOE/DELETE',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deleteConfirmController,
              decoration: const InputDecoration(
                labelText: 'Confirmation text',
              ),
            ),
          ],
        ),
       
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (_deleteConfirmController.text.trim() == '${_lastNameController.text.toUpperCase()}/DELETE') {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted (mocked).')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Confirmation failed. Please try again.')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
              title: 'Settings',
              subtitle: 'Configure your preferences',
              icon: Icons.settings,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [

                    /// Doctor Profile Section
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Doctor Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  // Add image picker later
                                  print('Profile image tapped');
                                },
                                child: const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFFEDE9FE), // Optional: soft purple background
                                  backgroundImage: AssetImage('assets/images/profile_image.png'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(labelText: 'First Name'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(labelText: 'Last Name'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Account Settings Section
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _currentPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Current Password'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'New Password'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Confirm Password'),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _changePassword,
                                child: const Text('Change Password'),
                              ),
                            ),
                            const Divider(height: 32),
                            Center(
                              child: TextButton(
                                onPressed: _deleteAccount,
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete My Account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
