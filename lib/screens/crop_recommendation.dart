import 'package:flutter/material.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  _CropRecommendationScreenState createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _recommendationResult;
  String? _recommendationDetails;

  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  // Define the custom colors based on the ARGB values
  static const Color primaryGreen = Color.fromARGB(255, 5, 150, 105);
  static const Color backgroundColor = Color.fromARGB(255, 240, 253, 244);

  @override
  void dispose() {
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    super.dispose();
  }

  void _recommendCrop() {
    if (_formKey.currentState!.validate()) {
      final double n = double.parse(_nController.text);
      final double p = double.parse(_pController.text);
      final double k = double.parse(_kController.text);
      final double temp = double.parse(_tempController.text);
      final double humidity = double.parse(_humidityController.text);
      final double ph = double.parse(_phController.text);
      final double rainfall = double.parse(
        _rainfallController.text,
      ); // Now included

      String crop = 'No Specific Recommendation';
      String details =
          'The entered conditions do not closely match any of the crops in our database. Please check your values.';

      // --- Expanded Rule-Based Logic (Sampled from real-world datasets) ---

      if (n >= 70 && n <= 100 && p >= 35 && p <= 50 && k >= 35 && k <= 50) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 70 &&
            humidity <= 90 &&
            ph >= 5.5 &&
            ph <= 6.5 &&
            rainfall >= 200 &&
            rainfall <= 300) {
          crop = 'Rice 🍚';
          details =
              'Rice requires high NPK values (especially N), high rainfall, and warm, humid conditions. Maintain water levels.';
        }
      } else if (n >= 60 &&
          n <= 80 &&
          p >= 30 &&
          p <= 60 &&
          k >= 20 &&
          k <= 40) {
        if (temp >= 20 &&
            temp <= 30 &&
            humidity >= 60 &&
            humidity <= 80 &&
            ph >= 5.5 &&
            ph <= 7.0 &&
            rainfall >= 50 &&
            rainfall <= 100) {
          crop = 'Maize 🌽';
          details =
              'Maize thrives in a wide range of conditions, preferring moderate NPK, warm temperatures, and moderate rainfall.';
        }
      } else if (n >= 10 &&
          n <= 30 &&
          p >= 60 &&
          p <= 80 &&
          k >= 60 &&
          k <= 80) {
        if (temp >= 18 &&
            temp <= 25 &&
            humidity >= 60 &&
            humidity <= 75 &&
            ph >= 6.0 &&
            ph <= 7.5 &&
            rainfall >= 50 &&
            rainfall <= 150) {
          crop = 'Kidney Beans (Rajma) 🌱';
          details =
              'Kidney Beans are leguminous, requiring lower N but high P and K for strong pod development. Prefers moderate temperatures.';
        }
      } else if (n >= 20 &&
          n <= 40 &&
          p >= 30 &&
          p <= 45 &&
          k >= 40 &&
          k <= 55) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 50 &&
            humidity <= 70 &&
            ph >= 6.5 &&
            ph <= 7.5 &&
            rainfall >= 70 &&
            rainfall <= 120) {
          crop = 'Pigeon Peas (Arhar) 🌿';
          details =
              'Pigeon Peas are hardy, needing moderate NPK and higher temperatures. They are drought-tolerant but benefit from moderate rain.';
        }
      } else if (n >= 0 &&
          n <= 20 &&
          p >= 20 &&
          p <= 40 &&
          k >= 20 &&
          k <= 40) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 30 &&
            humidity <= 50 &&
            ph >= 7.0 &&
            ph <= 8.0 &&
            rainfall >= 30 &&
            rainfall <= 70) {
          crop = 'Moth Beans 🌾';
          details =
              'Moth Beans are extremely drought-tolerant, requiring low NPK and thriving in high heat and low humidity. Perfect for arid regions.';
        }
      } else if (n >= 10 &&
          n <= 30 &&
          p >= 15 &&
          p <= 25 &&
          k >= 15 &&
          k <= 25) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 40 &&
            humidity <= 60 &&
            ph >= 5.5 &&
            ph <= 6.5 &&
            rainfall >= 60 &&
            rainfall <= 120) {
          crop = 'Cotton 🧶';
          details =
              'Cotton needs a moderate temperature, dry weather during harvest, and is sensitive to heavy rain. Prefers low to moderate NPK.';
        }
      } else if (n >= 20 &&
          n <= 30 &&
          p >= 100 &&
          p <= 120 &&
          k >= 100 &&
          k <= 120) {
        if (temp >= 10 &&
            temp <= 20 &&
            humidity >= 65 &&
            humidity <= 80 &&
            ph >= 6.0 &&
            ph <= 7.0 &&
            rainfall >= 60 &&
            rainfall <= 120) {
          crop = 'Apple 🍎';
          details =
              'Apple requires high P and K for flowering and fruiting, a lower temperature for chilling, and moderate humidity/rainfall.';
        }
      } else if (n >= 80 &&
          n <= 100 &&
          p >= 30 &&
          p <= 40 &&
          k >= 30 &&
          k <= 40) {
        if (temp >= 15 &&
            temp <= 25 &&
            humidity >= 60 &&
            humidity <= 80 &&
            ph >= 6.0 &&
            ph <= 6.5 &&
            rainfall >= 150 &&
            rainfall <= 250) {
          crop = 'Coffee ☕';
          details =
              'Coffee thrives in cool, humid, high-rainfall areas with fertile, slightly acidic soil. Requires high N for leaf growth.';
        }
      } else if (n >= 80 &&
          n <= 110 &&
          p >= 70 &&
          p <= 90 &&
          k >= 40 &&
          k <= 60) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 75 &&
            humidity <= 85 &&
            ph >= 6.0 &&
            ph <= 7.0 &&
            rainfall >= 100 &&
            rainfall <= 200) {
          crop = 'Banana 🍌';
          details =
              'Banana needs high N, P, and K, high temperature, high humidity, and plenty of rain. Sensitive to cold.';
        }
      } else if (n >= 60 &&
          n <= 80 &&
          p >= 40 &&
          p <= 50 &&
          k >= 40 &&
          k <= 50) {
        if (temp >= 25 &&
            temp <= 35 &&
            humidity >= 50 &&
            humidity <= 60 &&
            ph >= 6.0 &&
            ph <= 7.0 &&
            rainfall >= 50 &&
            rainfall <= 100) {
          crop = 'Watermelon 🍉';
          details =
              'Watermelon needs high heat and plenty of sunshine. Prefers deep, well-drained soil and moderate NPK levels.';
        }
      }

      _setResult(crop, details);
    }
  }

  void _setResult(String crop, String details) {
    setState(() {
      _recommendationResult = crop;
      _recommendationDetails = details;
    });
  }

  // --- UI Component for Result Card ---
  Widget _buildResultCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _recommendationResult != null
          ? Card(
              key: const ValueKey<int>(1), // Unique key for AnimatedSwitcher
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: const EdgeInsets.symmetric(vertical: 24.0),
              color: primaryGreen.withOpacity(0.1), // Unique Card color
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Recommendation Found!',
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendationResult!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                      ),
                    ),
                    const Divider(
                      color: primaryGreen,
                      height: 20,
                      thickness: 2,
                    ),
                    const Text(
                      'Cultivation Notes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendationDetails!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(
              key: ValueKey<int>(0),
            ), // Key to trigger transition
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Smart Crop Recommendation'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter your soil and environmental data to get the best crop suggestion. All values are required.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInputField('Nitrogen (N) Ratio', _nController, 'Ratio'),
              _buildInputField('Phosphorus (P) Ratio', _pController, 'Ratio'),
              _buildInputField('Potassium (K) Ratio', _kController, 'Ratio'),
              _buildInputField('Temperature', _tempController, '°C'),
              _buildInputField('Humidity', _humidityController, '%'),
              _buildInputField('pH Value', _phController, ''),
              _buildInputField('Rainfall', _rainfallController, 'mm'),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _recommendCrop,
                icon: const Icon(Icons.psychology_alt),
                label: const Text('ANALYZE & RECOMMEND'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Component for Input Fields ---
  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          prefixIcon: _getIconForLabel(label),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value for $label';
          }
          final double? parsedValue = double.tryParse(value);
          if (parsedValue == null) {
            return 'Please enter a valid number';
          }
          if (label.contains('pH') && (parsedValue < 0 || parsedValue > 14)) {
            return 'pH must be between 0 and 14';
          }
          return null;
        },
      ),
    );
  }

  // --- Utility for Input Field Icons ---
  Icon _getIconForLabel(String label) {
    switch (label) {
      case 'Nitrogen (N) Ratio':
      case 'Phosphorus (P) Ratio':
      case 'Potassium (K) Ratio':
        return const Icon(Icons.science, color: primaryGreen);
      case 'Temperature':
        return const Icon(Icons.thermostat, color: primaryGreen);
      case 'Humidity':
        return const Icon(Icons.cloud_queue, color: primaryGreen);
      case 'pH Value':
        return const Icon(Icons.grain, color: primaryGreen);
      case 'Rainfall':
        return const Icon(Icons.umbrella, color: primaryGreen);
      default:
        return const Icon(Icons.grass, color: primaryGreen);
    }
  }
}
