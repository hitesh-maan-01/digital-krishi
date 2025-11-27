import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import all screens
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
//import 'Authentication/login_page.dart';
import 'community/community_list_page.dart';
import 'Authentication/onboarding_page.dart';

import 'package:firebase_core/firebase_core.dart'; // ADDED

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uezozemoslqcalxyamdz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlem96ZW1vc2xxY2FseHlhbWR6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4MzYzMzMsImV4cCI6MjA3MzQxMjMzM30.L6ZL8mB_vbt0T886wHaMI3tKWRyF9vZWaEGnCAwm2kQ',
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  //Initialize Firebase
  await Firebase.initializeApp(); // ADDED

  // Initialize Hive
  await Hive.initFlutter();

  // Open Hive box for storing market prices
  await Hive.openBox('marketPrices');

  runApp(const DigitalKrishiApp());
}

class DigitalKrishiApp extends StatelessWidget {
  const DigitalKrishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Krishi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/', // Start with splash screen
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const OnboardingPage(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    const CommunityListPage(),
    FarmerProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 5, 150, 105),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
