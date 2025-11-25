import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'weather_model.dart';

class WeatherService {
  final String apiKey = "R42pcChSst2JGmdQY94ng5ZV4aR8wLwV";
  final String baseUrl = "https://api.tomorrow.io/v4/timelines";

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      "$baseUrl?location=$lat,$lon&fields=temperature,temperatureApparent,humidity,windSpeed,pressureSeaLevel,weatherCode,precipitationProbability,sunriseTime,sunsetTime,temperatureMax,temperatureMin&timesteps=1h,1d&units=metric&apikey=$apiKey",
    );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception("Failed to fetch weather: ${res.body}");
    }

    final data = jsonDecode(res.body);
    final parsed = _parseWeatherData(data);

    // Save locally for offline mode
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "lastWeather",
      jsonEncode({
        "lat": lat,
        "lon": lon,
        "data": {
          "current": (parsed["current"] as Weather).toJson(),
          "hourly": (parsed["hourly"] as List<HourlyForecast>)
              .map((e) => e.toJson())
              .toList(),
          "daily": (parsed["daily"] as List<DailyForecast>)
              .map((e) => e.toJson())
              .toList(),
        },
      }),
    );

    return parsed;
  }

  Future<Map<String, dynamic>?> loadOfflineWeather() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("lastWeather");
    if (saved == null) return null;

    final data = jsonDecode(saved)["data"];

    final current = Weather.fromJson({"values": data["current"]});
    final hourly = (data["hourly"] as List)
        .map((e) => HourlyForecast.fromJson({"time": e["time"], "values": e}))
        .toList();
    final daily = (data["daily"] as List)
        .map((e) => DailyForecast.fromJson({"time": e["time"], "values": e}))
        .toList();

    return {"current": current, "hourly": hourly, "daily": daily};
  }

  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final geoUrl = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1",
    );
    final geoRes = await http.get(geoUrl);

    if (geoRes.statusCode != 200) {
      throw Exception("Failed to geocode city");
    }
    final geo = jsonDecode(geoRes.body);
    if (geo["results"] == null || geo["results"].isEmpty) {
      throw Exception("City not found");
    }

    final lat = geo["results"][0]["latitude"];
    final lon = geo["results"][0]["longitude"];
    return fetchWeather(lat, lon);
  }

  Map<String, dynamic> _parseWeatherData(Map<String, dynamic> data) {
    final timelines = data["data"]["timelines"];
    final hourly = timelines.firstWhere((t) => t["timestep"] == "1h");
    final daily = timelines.firstWhere((t) => t["timestep"] == "1d");

    final currentValues = hourly["intervals"].first["values"];

    final current = Weather(
      temperature: (currentValues["temperature"] ?? 0).toDouble(),
      windSpeed: (currentValues["windSpeed"] ?? 0).toDouble(),
      weatherCode: (currentValues["weatherCode"] ?? 0).toInt(),
      precipitationProbability: (currentValues["precipitationProbability"] ?? 0)
          .toDouble(),
      humidity: (currentValues["humidity"] ?? 0).toDouble(),
      feelsLike: (currentValues["temperatureApparent"] ?? 0).toDouble(),
      pressure: (currentValues["pressureSeaLevel"] ?? 0).toDouble(),
      sunrise: DateTime.tryParse(currentValues["sunriseTime"] ?? ""),
      sunset: DateTime.tryParse(currentValues["sunsetTime"] ?? ""),
    );

    final hourlyForecast = (hourly["intervals"] as List)
        .take(24)
        .map((e) => HourlyForecast.fromJson(e))
        .toList();

    final dailyForecast = (daily["intervals"] as List)
        .take(6)
        .map((e) => DailyForecast.fromJson(e))
        .toList();

    return {
      "current": current,
      "hourly": hourlyForecast,
      "daily": dailyForecast,
    };
  }
}
