import 'package:flutter/material.dart';
import '../routes.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;        // for the login button
  bool _checkingSession = true;   // for the initial silent login check
  bool _rememberMe = true;        // "Stay logged in"

  @override
  void initState() {
    super.initState();
    _trySilentLogin();
  }

  Future<void> _trySilentLogin() async {
    // If a refresh token exists and is valid, skip login UI.
    try {
      final ok = await _apiService.tryRefreshOnce();
      if (!mounted) return;
      if (ok) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
        return;
      }
    } catch (_) {
      // ignore; will fall back to login form
    }
    if (mounted) setState(() => _checkingSession = false);
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final success = await _apiService.login(
      _usernameController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe, // 👈 persist refresh token only if checked
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed, please check credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      // Minimal splash while we try silent login
      return const Scaffold(
        body: Center(
          child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to AIDentify–EndoApp',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to access your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => _isLoading ? null : _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: _isLoading ? null : (v) => setState(() => _rememberMe = v ?? true),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Stay logged in', style: TextStyle(fontSize: 14))),
                    ],
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Log In', style: TextStyle(fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: null, // Google OAuth disabled
                      icon: Image.asset('assets/images/g-logo.png', height: 20, width: 20),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(context, Routes.register),
                    child: Text(
                      'Don\'t have an account? Register',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
