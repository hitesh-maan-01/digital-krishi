// ignore_for_file: depend_on_referenced_packages, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'weather_model.dart';
import 'weather_utils.dart';

// --- 1. Custom Theme Colors ---
const Color kDaySkyBlue = Color(0xFF87CEEB);
const Color kNightIndigo = Color(0xFF303F9F);
const Color kAccentGold = Color(0xFFFFC107);
const Color kLightBackground = Color(0xFFFAFAFA);

class WeatherPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _service = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  Weather? _current;
  List<HourlyForecast> _hourly = [];
  List<DailyForecast> _daily = [];
  bool _loading = true;
  String _city = "";

  @override
  void initState() {
    super.initState();
    _loadWeather(widget.latitude, widget.longitude);
  }

  Future<void> _loadWeather(double lat, double lon) async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchWeather(lat, lon);
      setState(() {
        _current = data["current"];
        _hourly = data["hourly"];
        _daily = data["daily"];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Weather fetch error: $e");
    }
  }

  Future<void> _searchCity() async {
    if (_searchController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final data = await _service.fetchWeatherByCity(
        _searchController.text.trim(),
      );
      setState(() {
        _current = data["current"];
        _hourly = data["hourly"];
        _daily = data["daily"];
        _city = _searchController.text.trim();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("City not found: ${_searchController.text.trim()}"),
        ),
      );
    }
  }

  // --- Helper for Dynamic Hourly Background ---
  Color _getHourlyBackgroundColor(
    DateTime time,
    DateTime? sunrise,
    DateTime? sunset,
  ) {
    if (sunrise == null || sunset == null) {
      // Fallback: simple night/day based on hour
      return time.hour >= 19 || time.hour < 6
          ? kNightIndigo.withOpacity(0.1)
          : kDaySkyBlue.withOpacity(0.1);
    }
    // Check if the current hour is between sunrise and sunset
    final isDaytime = time.isAfter(sunrise) && time.isBefore(sunset);
    return isDaytime
        ? kDaySkyBlue.withOpacity(0.1)
        : kNightIndigo.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Themed AppBar: Transparent ---
      appBar: AppBar(
        title: Text("Weather Forecast", style: GoogleFonts.poppins()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false, // Align title to the left
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      // --- Themed Scaffold Body Background Gradient ---
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kLightBackground, Color(0xFFEFEFEF)],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: kDaySkyBlue))
            : RefreshIndicator(
                onRefresh: () =>
                    _loadWeather(widget.latitude, widget.longitude),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search bar (Enhanced style)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: "Enter city name",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: kDaySkyBlue,
                                size: 30,
                              ),
                              onPressed: _searchCity,
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- 2. Current Weather Card Enhancement ---
                        if (_current != null)
                          Container(
                            // Card Gradient/Shape
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB2EBF2), kDaySkyBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: kDaySkyBlue.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 24,
                                    left: 24,
                                    right: 24,
                                    bottom: 16,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        _city.isNotEmpty
                                            ? _city
                                            : "Current Location",
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      // Use Emoji from WeatherUtils
                                      Text(
                                        WeatherUtils.getWeatherEmoji(
                                          _current!.weatherCode,
                                        ),
                                        style: const TextStyle(fontSize: 80),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${_current!.temperature.toStringAsFixed(1)}°C",
                                        style: GoogleFonts.poppins(
                                          fontSize: 60,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Feels Like: ${_current!.feelsLike.toStringAsFixed(1)}°C",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildDetail(
                                            Icons.water_drop,
                                            "${_current!.humidity.toStringAsFixed(0)}%",
                                            "Humidity",
                                          ),
                                          _buildDetail(
                                            Icons.air,
                                            "${_current!.windSpeed.toStringAsFixed(0)}km/h",
                                            "Wind Speed",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Use a Banner for Weather Condition
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kAccentGold.withOpacity(0.95),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      WeatherUtils.getWeatherCondition(
                                        _current!.weatherCode,
                                      ).toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Hourly Forecast
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Next 24 Hours",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _hourly.length,
                            itemBuilder: (context, index) {
                              final hour = _hourly[index];
                              final sequentialTime = DateTime.now().add(
                                Duration(hours: index),
                              );
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                padding: const EdgeInsets.all(12),
                                // --- 3. Dynamic Backgrounds for Hourly ---
                                decoration: BoxDecoration(
                                  color: _getHourlyBackgroundColor(
                                    sequentialTime,
                                    _current?.sunrise,
                                    _current?.sunset,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: kDaySkyBlue.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Increased Spacing
                                    Text(
                                      DateFormat.j().format(sequentialTime),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Use smaller icons (assuming a code of 1000 for simplicity)
                                    Icon(
                                      WeatherUtils.getWeatherIcon(
                                        hour.weatherCode,
                                      ),
                                      color: kDaySkyBlue,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${hour.temperature.toStringAsFixed(0)}°C",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      "💧${hour.precipitationProbability.toStringAsFixed(0)}%",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: kNightIndigo,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Daily Forecast
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "6-Day Forecast",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          // --- 4. Daily Forecast Enhancement ---
                          children: _daily.asMap().entries.map((entry) {
                            final index = entry.key;
                            final day = entry.value;

                            String getDayLabel(int index) {
                              if (index == 0) return "Today";
                              if (index == 1) return "Tomorrow";
                              final sequentialDay = DateTime.now().add(
                                Duration(days: index),
                              );
                              return DateFormat('EEEE').format(sequentialDay);
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 3,
                              child: ListTile(
                                // Use Weather Emoji as the leading icon
                                leading: Text(
                                  WeatherUtils.getWeatherEmoji(
                                    day.precipitationProbability > 40
                                        ? 4000
                                        : 1000,
                                  ),
                                  style: const TextStyle(fontSize: 32),
                                ),
                                title: Text(
                                  getDayLabel(index),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // Prominent Max/Min Temperatures
                                subtitle: Row(
                                  children: [
                                    Text(
                                      "Max: ${day.maxTemperature.toStringAsFixed(0)}°C",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      "Min: ${day.minTemperature.toStringAsFixed(0)}°C",
                                      style: GoogleFonts.poppins(
                                        color: kNightIndigo.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  "💧${day.precipitationProbability.toStringAsFixed(0)}%",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: kNightIndigo,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // Helper widget for current weather card details
  Widget _buildDetail(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
