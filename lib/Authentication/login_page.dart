// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:digital_krishi/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_page.dart';
//import '../screens/home_page.dart';

// --- Shared Constants for Theme ---
const Color _primaryGreen = Color(0xFF4CAF50); // Lighter Green
const Color _darkGreen = Color(0xFF388E3C); // Darker Green (for buttons)
const String _bgImagePath =
    'assets/log_page/plants_bg.jpg'; // Path to your background image

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _rememberMe = false; // Added for the 'Remember me' checkbox

  Future<void> login() async {
    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else {
        // ... (Error handling remains the same)
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents overflow when keyboard appears
      body: Stack(
        children: [
          // 1. Background Image
          // NOTE: You must add an image asset (e.g., 'assets/plants_bg.jpg')
          // and declare it in your pubspec.yaml file for this to work.
          Image.asset(
            _bgImagePath, // Replace with your actual asset path
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),

          // 2. White Card with Curved Top
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.25, // Start 25% down
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    // We remove the AppBar and use a custom back button on the card
                    // to match the design.
                    InkWell(
                      onTap: () => Navigator.of(context).pop(), // Go back
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Text
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    const Text(
                      'Login to your account',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    // Email/Username Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email / Username',
                        border: const UnderlineInputBorder(),
                        suffixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.grey,
                        ),
                        floatingLabelStyle: const TextStyle(color: _darkGreen),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const UnderlineInputBorder(),
                        suffixIcon: const Icon(
                          Icons.visibility_off_outlined,
                          color: Colors.grey,
                        ),
                        floatingLabelStyle: const TextStyle(color: _darkGreen),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),

                    // Remember Me and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() => _rememberMe = val ?? false);
                              },
                              activeColor: _primaryGreen,
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement Forgot Password logic
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account? '),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupPage(),
                            ),
                          ),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: _darkGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
          // App Logo over the background
          Positioned(
            top: MediaQuery.of(context).padding.top + 30, // Position it nicely
            left: 0,
            right: 0,
            child: const Center(
              child: Icon(
                Icons.filter_vintage,
                size: 40,
                color: Colors.white,
              ), // Using a plant-like icon
            ),
          ),
        ],
      ),
    );
  }
}
