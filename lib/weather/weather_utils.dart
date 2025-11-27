import 'package:flutter/material.dart';

class WeatherUtils {
  static IconData getWeatherIcon(int code) {
    if (code == 1000) return Icons.wb_sunny; // clear
    if (code >= 1001 && code <= 1100) return Icons.wb_cloudy; // clouds
    if (code >= 4000 && code <= 4201) return Icons.grain; // rain
    if (code >= 5000 && code <= 6000) return Icons.ac_unit; // snow
    if (code >= 8000) return Icons.flash_on; // thunder
    return Icons.help_outline;
  }

  static String getWeatherEmoji(int code) {
    if (code == 1000) return "☀️";
    if (code >= 1001 && code <= 1100) return "☁️";
    if (code >= 4000 && code <= 4201) return "🌧️";
    if (code >= 5000 && code <= 6000) return "❄️";
    if (code >= 8000) return "⚡";
    return "❓";
  }

  static String getWeatherCondition(int code) {
    if (code == 1000) return "Clear Skies";
    if ([1100, 1101].contains(code)) return "Mostly Sunny / Partly Cloudy";
    if (code == 1001) return "Cloudy";
    if ([4000, 4200, 4201].contains(code)) return "Rain / Showers";
    if ([5000, 5001].contains(code)) return "Snow";
    if (code >= 8000) return "Thunderstorms";
    return "Variable Weather";
  }
}
