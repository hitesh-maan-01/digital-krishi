import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';

import '../weather/weather_page.dart';
import '../weather/weather_service.dart';
import '../weather/weather_model.dart';
import '../chatbot/chatbot_page.dart';
import 'disease_page.dart';
import '../marketPrice/market_price_page.dart';
import 'drip_irrigation.dart';
import 'crop_calendar_page.dart';
import 'organic_farming.dart';
import 'notifications_page.dart';
import 'menu_page.dart';
import 'package:digital_krishi/crop_recommendation.dart';
import 'schemes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentFocusIndex = 0;
  final PageController _pageController = PageController();
  final WeatherService _weatherService = WeatherService();
  Weather? _currentWeather;
  bool _loadingWeather = true;
  String _city = "Fetching...";
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _autoSlideFocus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingWeather = true;
      _city = "Fetching...";
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _city = "Location Denied";
          _loadingWeather = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _city = placemarks.first.locality ?? "Unknown City";
      });

      final weatherData = await _weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentWeather = weatherData["current"];
        _loadingWeather = false;
      });

      debugPrint("Weather fetched successfully for $_city");
    } catch (e) {
      debugPrint("Error fetching location/weather: $e");

      final offline = await _weatherService.loadOfflineWeather();
      if (offline != null) {
        setState(() {
          _currentWeather = offline["current"];
          _city = "Offline Data";
        });
      }

      setState(() {
        _loadingWeather = false;
      });
    }
  }

  void _autoSlideFocus() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        int nextPage = (_currentFocusIndex + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        setState(() => _currentFocusIndex = nextPage);
        _autoSlideFocus();
      }
    });
  }

  /// WEATHER HEADER
  Widget _buildWeatherSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 5, 150, 105),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            "Digital Krishi",
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          _loadingWeather
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "$_city\n"
                        "🌡 ${_currentWeather?.temperature.toStringAsFixed(1) ?? "--"}°C   "
                        "💧 ${_currentWeather?.humidity.toStringAsFixed(0) ?? "--"}%",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_latitude != null && _longitude != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WeatherPage(
                                latitude: _latitude!,
                                longitude: _longitude!,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 5, 150, 105),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("View Forecast"),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  /// TODAY'S FOCUS
  Widget _buildTodayFocusSection() {
    List<String> focusMessages = [
      "🌾 High risk of pest infestation in maize crops today!",
      "💧 Rainfall expected, schedule irrigation carefully.",
      "📈 Market prices updated, check your crop rates now!",
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      height: 100,
      child: PageView.builder(
        controller: _pageController,
        itemCount: focusMessages.length,
        onPageChanged: (index) => setState(() => _currentFocusIndex = index),
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                focusMessages[index],
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  /// QUICK ACTIONS
  Widget _buildQuickActions() {
    List<Map<String, dynamic>> actions = [
      {
        "title": "Pest Detection",
        "icon": "assets/icons/pest.png",
        "page": const DiseasePage(),
      },
      {
        "title": "Chat with AI",
        "icon": "assets/icons/chat.png",
        "page": const ChatbotPage(),
      },
      {
        "title": "Market Price",
        "icon": "assets/icons/market.png",
        "page": const MarketPricePage(),
      },
      {
        "title": "Schemes & Subsidies",
        "icon": "assets/icons/recommendation.png",
        "page": SchemesPage(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildCard(action["title"], action["icon"], () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => action["page"]),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  /// FARMING TOOLS
  Widget _buildFarmingTools() {
    List<Map<String, dynamic>> tools = [
      {
        "title": " Drip Irrigation ",
        "icon": "assets/icons/irrigation.png",
        "page": const DripIrrigationScreen(),
      },
      {
        "title": "Organic Farming",
        "icon": "assets/icons/fertilizer.png",
        "page": const OrganicFarmingScreen(),
      },
      {
        "title": "Crop Recommendation",
        "icon": "assets/icons/recommendation.png",
        "page": const CropRecommendationScreen(),
      },
      {
        "title": "Crop Calendar",
        "icon": "assets/icons/calendar.png",
        "page": const SowingCalendarPage(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Farming Tools & Advice",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return _buildCard(tool["title"], tool["icon"], () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => tool["page"]),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String iconPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 50, width: 50),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 5, 150, 105),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      drawer: const MenuPage(),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _getCurrentLocation,
          color: Colors.white,
          backgroundColor: const Color.fromARGB(255, 5, 150, 105),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWeatherSection(),
                _buildTodayFocusSection(),
                _buildQuickActions(),
                _buildFarmingTools(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
