class Weather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final double precipitationProbability;
  final double humidity;
  final double feelsLike;
  final double pressure;
  final DateTime? sunrise;
  final DateTime? sunset;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.humidity,
    required this.feelsLike,
    required this.pressure,
    this.sunrise,
    this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final values = json['values'] ?? {};
    return Weather(
      temperature: (values['temperature'] ?? 0).toDouble(),
      windSpeed: (values['windSpeed'] ?? 0).toDouble(),
      weatherCode: (values['weatherCode'] ?? 0).toInt(),
      precipitationProbability: (values['precipitationProbability'] ?? 0)
          .toDouble(),
      humidity: (values['humidity'] ?? 0).toDouble(),
      feelsLike: (values['temperatureApparent'] ?? 0).toDouble(),
      pressure: (values['pressureSeaLevel'] ?? 0).toDouble(),
      sunrise: DateTime.tryParse(values['sunriseTime'] ?? ""),
      sunset: DateTime.tryParse(values['sunsetTime'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "temperature": temperature,
    "windSpeed": windSpeed,
    "weatherCode": weatherCode,
    "precipitationProbability": precipitationProbability,
    "humidity": humidity,
    "feelsLike": feelsLike,
    "pressure": pressure,
    "sunrise": sunrise?.toIso8601String(),
    "sunset": sunset?.toIso8601String(),
  };
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double windSpeed;
  final double precipitationProbability;
  final int weatherCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.weatherCode,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final values = json['values'] ?? {};
    return HourlyForecast(
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      temperature: (values['temperature'] ?? 0).toDouble(),
      windSpeed: (values['windSpeed'] ?? 0).toDouble(),
      precipitationProbability: (values['precipitationProbability'] ?? 0)
          .toDouble(),
      weatherCode: (values['weatherCode'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    "time": time.toIso8601String(),
    "temperature": temperature,
    "windSpeed": windSpeed,
    "precipitationProbability": precipitationProbability,
    "weatherCode": weatherCode,
  };
}

class DailyForecast {
  final DateTime time;
  final double maxTemperature;
  final double minTemperature;
  final double precipitationProbability;

  DailyForecast({
    required this.time,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbability,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final values = json['values'] ?? {};
    return DailyForecast(
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      maxTemperature: (values['temperatureMax'] ?? 0).toDouble(),
      minTemperature: (values['temperatureMin'] ?? 0).toDouble(),
      precipitationProbability: (values['precipitationProbability'] ?? 0)
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "time": time.toIso8601String(),
    "maxTemperature": maxTemperature,
    "minTemperature": minTemperature,
    "precipitationProbability": precipitationProbability,
  };
}
