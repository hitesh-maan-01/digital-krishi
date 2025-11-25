// onboarding_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack to layer the background image, the gradient, and the content.
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          // NOTE: You must add an image asset (e.g., 'assets/plants_bg.jpg')
          // and declare it in your pubspec.yaml file for this to work.
          // For now, I'll use a deep green color with a placeholder asset path.
          Image.asset(
            'assets/log_page/plants_bg.jpg', // Replace with your actual asset path
            fit: BoxFit.cover,
          ),

          // 2. Dark Overlay Gradient for better text readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.6, 1.0], // Start darkening near the bottom
              ),
            ),
          ),

          // 3. Content (Text and Buttons)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DIGITAL \n KRISHI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                // Sign Up Button (Green Outline / Filled)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF388E3C), // Darker green
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFF388E3C),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Button (Filled Green)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C), // Darker green
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
