import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weather_service.dart';
import 'weather_model.dart';

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
        SnackBar(content: Text("City not found: $_searchController")),
      );
    }
  }

  IconData _getWeatherIcon(int code, bool isNight) {
    if (isNight) {
      return Icons.nights_stay;
    }
    if (code == 1000) return Icons.wb_sunny;
    if ([1100, 1101].contains(code)) return Icons.cloud;
    if ([4000, 4200].contains(code)) return Icons.grain;
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Forecast", style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
        titleTextStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadWeather(widget.latitude, widget.longitude),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Enter city name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.teal),
                            onPressed: _searchCity,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Current Weather
                      if (_current != null)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  _city.isNotEmpty ? _city : "Your Location",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Icon(
                                  _getWeatherIcon(
                                    _current!.weatherCode,
                                    DateTime.now().hour >= 18,
                                  ),
                                  size: 60,
                                  color: Colors.teal,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${_current!.temperature.toStringAsFixed(1)}°C",
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Humidity: ${_current!.humidity.toStringAsFixed(0)}%",
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Hourly Forecast
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Next 24 Hours",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _hourly.length,
                          itemBuilder: (context, index) {
                            final hour = _hourly[index];
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${hour.time.hour}:00",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(Icons.thermostat, color: Colors.teal),
                                  Text(
                                    "${hour.temperature.toStringAsFixed(0)}°C",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Daily Forecast
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "7-Day Forecast",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: _daily.map((day) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.calendar_today,
                                color: Colors.teal,
                              ),
                              title: Text(
                                "${day.time.day}/${day.time.month}/${day.time.year}",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "Min: ${day.minTemperature.toStringAsFixed(0)}°C, Max: ${day.maxTemperature.toStringAsFixed(0)}°C",
                                style: GoogleFonts.poppins(),
                              ),
                              trailing: Text(
                                "💧${day.precipitationProbability.toStringAsFixed(0)}%",
                                style: GoogleFonts.poppins(),
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
    );
  }
}
