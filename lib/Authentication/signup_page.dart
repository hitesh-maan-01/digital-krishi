import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/home_page.dart';
import 'login_page.dart'; // Import to link back

// --- Shared Constants for Theme ---
const Color _primaryGreen = Color(0xFF4CAF50); // Lighter Green
const Color _darkGreen = Color(0xFF388E3C); // Darker Green (for buttons)
const String _bgImagePath =
    'assets/log_page/plants_bg.jpg'; // Path to your background image

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController(); // Added Confirm Password
  bool loading = false;

  Future<void> signup() async {
    // Basic validation
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup failed: Passwords do not match.'),
          ),
        );
      }
      return;
    }

    setState(() => loading = true);
    try {
      final supabase = Supabase.instance.client;

      // Sign up with name in metadata - the trigger will handle profile creation
      final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'name': nameController.text
              .trim(), // This gets stored in raw_user_meta_data
        },
      );

      final user = authResponse.user;
      if (user != null) {
        // No need to manually insert into users table - trigger handles it
        if (context.mounted) {
          // Navigate to home page after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        throw Exception('User creation failed');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
      }
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
                    InkWell(
                      onTap: () => Navigator.of(context).pop(), // Go back
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Text
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    const Text(
                      'Create your new account',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    // First Name Field
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                        floatingLabelStyle: TextStyle(color: _darkGreen),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Last Name Field - Placeholder, assuming design uses two name fields
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                        floatingLabelStyle: TextStyle(color: _darkGreen),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                        floatingLabelStyle: TextStyle(color: _darkGreen),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                        floatingLabelStyle: TextStyle(color: _darkGreen),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),

                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: _darkGreen),
                        ),
                        floatingLabelStyle: TextStyle(color: _darkGreen),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    // Terms and Privacy Policy
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'By signing you agree to our Terms of use and privacy policy.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : signup,
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
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        InkWell(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          ),
                          child: const Text(
                            'Login',
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
