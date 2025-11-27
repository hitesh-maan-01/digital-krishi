import 'package:digital_krishi/Authentication/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- ADD THIS IMPORT
import '../community/community_list_page.dart';
import 'profile_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  // Function to handle sign out
  Future<void> _signOut(BuildContext context) async {
    try {
      // 1. Clear the Supabase session
      await Supabase.instance.client.auth.signOut();

      // 2. Navigate to the Onboarding Page and remove all previous routes
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 5, 150, 105),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color.fromARGB(255, 5, 150, 105),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome, Farmer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Updated to navigate to the ProfilePage
            _buildMenuItem(context, Icons.person_rounded, 'Profile', () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FarmerProfilePage()),
              );
            }),

            // Updated to navigate to the CommunityPage
            _buildMenuItem(context, Icons.group_rounded, 'Community', () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunityListPage(),
                ),
              );
            }),
            _buildMenuItem(
              context,
              Icons.school_rounded,
              'Tutorials for Digital Krishi',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tapped on Tutorials')),
                );
                Navigator.pop(context);
              },
            ),
            _buildMenuItem(context, Icons.help_rounded, 'Help', () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Tapped on Help')));
              Navigator.pop(context);
            }),
            const Divider(),
            _buildMenuItem(context, Icons.language_rounded, 'Language', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapped on Language')),
              );
              Navigator.pop(context);
            }),
            _buildMenuItem(context, Icons.info_rounded, 'About', () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Tapped on About')));
              Navigator.pop(context);
            }),
            _buildMenuItem(context, Icons.settings_rounded, 'Settings', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapped on Settings')),
              );
              Navigator.pop(context);
            }),
            // *** UPDATED SIGN OUT LOGIC ***
            _buildMenuItem(context, Icons.exit_to_app, 'Sign out', () {
              Navigator.pop(context); // Close the drawer immediately
              _signOut(context); // Call the sign-out function
            }),
          ],
        ),
      ),
    );
  }

  // Updated `_buildMenuItem` to accept a VoidCallback for onTap
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 5, 150, 105)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      onTap: onTap,
    );
  }
}
