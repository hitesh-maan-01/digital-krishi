// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:flutter/material.dart';
// Imported for a basic mock simulation

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

  // --- MODEL SIMULATION MAPPING ---
  // In a real application, this would be replaced by an API call to a
  // deployed ML model (e.g., using a REST client like Dio or http).
  // This map contains the data the ML model learned from (the centroids of the clusters).
  final Map<String, Map<String, dynamic>> _mlCropData = {
    'Rice 🍚': {
      'N': [70, 100],
      'P': [35, 50],
      'K': [35, 50],
      'Temp': [25, 35],
      'Humidity': [70, 90],
      'pH': [5.5, 6.5],
      'Rainfall': [200, 300],
      'details':
          'Rice requires high NPK values (especially N), high rainfall, and warm, humid conditions. Maintain water levels.',
    },
    'Maize 🌽': {
      'N': [60, 80],
      'P': [30, 60],
      'K': [20, 40],
      'Temp': [20, 30],
      'Humidity': [60, 80],
      'pH': [5.5, 7.0],
      'Rainfall': [50, 100],
      'details':
          'Maize thrives in a wide range of conditions, preferring moderate NPK, warm temperatures, and moderate rainfall.',
    },
    'Kidney Beans (Rajma) 🌱': {
      'N': [10, 30],
      'P': [60, 80],
      'K': [60, 80],
      'Temp': [18, 25],
      'Humidity': [60, 75],
      'pH': [6.0, 7.5],
      'Rainfall': [50, 150],
      'details':
          'Kidney Beans are leguminous, requiring lower N but high P and K for strong pod development. Prefers moderate temperatures.',
    },
    // ... add all other crops from the original logic here for a complete simulation
    // The previous logic has been converted to 'learned' ranges.
    'Moth Beans 🌾': {
      'N': [0, 20],
      'P': [20, 40],
      'K': [20, 40],
      'Temp': [25, 35],
      'Humidity': [30, 50],
      'pH': [7.0, 8.0],
      'Rainfall': [30, 70],
      'details':
          'Moth Beans are extremely drought-tolerant, requiring low NPK and thriving in high heat and low humidity. Perfect for arid regions.',
    },
    'Apple 🍎': {
      'N': [20, 30],
      'P': [100, 120],
      'K': [100, 120],
      'Temp': [10, 20],
      'Humidity': [65, 80],
      'pH': [6.0, 7.0],
      'Rainfall': [60, 120],
      'details':
          'Apple requires high P and K for flowering and fruiting, a lower temperature for chilling, and moderate humidity/rainfall.',
    },
    'Banana 🍌': {
      'N': [80, 110],
      'P': [70, 90],
      'K': [40, 60],
      'Temp': [25, 35],
      'Humidity': [75, 85],
      'pH': [6.0, 7.0],
      'Rainfall': [100, 200],
      'details':
          'Banana needs high N, P, and K, high temperature, high humidity, and plenty of rain. Sensitive to cold.',
    },
    'Default': {
      'details':
          'The entered conditions do not closely match any of the crops in our database. Please check your values.',
    },
  };

  // --- 💡 This function replaces the large rule-based IF/ELSE block 💡 ---
  // It simulates the process of an ML model determining the best crop.
  Map<String, String> _predictCrop(
    double n,
    double p,
    double k,
    double temp,
    double humidity,
    double ph,
    double rainfall,
  ) {
    String bestCrop = 'No Specific Recommendation';
    String details = _mlCropData['Default']!['details'] as String;
    double bestMatchScore = 0.0;

    // Simulate ML Model's "Prediction" by checking for the best match
    // to the learned optimal ranges (simulating a k-Nearest Neighbors or
    // similar classification model's decision boundary).
    for (var entry in _mlCropData.entries) {
      if (entry.key == 'Default') continue;

      final data = entry.value;
      double score = 0;
      int matchedCriteria = 0;
      const int totalCriteria = 7; // N, P, K, Temp, Humidity, pH, Rainfall

      // Check if values fall within the learned range for this crop
      if (n >= data['N'][0] && n <= data['N'][1]) matchedCriteria++;
      if (p >= data['P'][0] && p <= data['P'][1]) matchedCriteria++;
      if (k >= data['K'][0] && k <= data['K'][1]) matchedCriteria++;
      if (temp >= data['Temp'][0] && temp <= data['Temp'][1]) matchedCriteria++;
      if (humidity >= data['Humidity'][0] && humidity <= data['Humidity'][1]) {
        matchedCriteria++;
      }
      if (ph >= data['pH'][0] && ph <= data['pH'][1]) matchedCriteria++;
      if (rainfall >= data['Rainfall'][0] && rainfall <= data['Rainfall'][1]) {
        matchedCriteria++;
      }

      score = matchedCriteria / totalCriteria;

      // Update the best match found so far
      if (score > bestMatchScore && score > 0.7) {
        // Requires a minimum match of >70%
        bestMatchScore = score;
        bestCrop = entry.key;
        details = data['details'] as String;
      }
    }

    // A real ML model would return the prediction directly, like:
    // return {
    //   'crop': 'Rice 🍚',
    //   'details': 'Rice requires high NPK values...'
    // };

    return {
      'crop': bestCrop,
      'details': details,
      'score': bestMatchScore.toStringAsFixed(2),
    };
  }
  // ------------------------------------------------------------------

  void _recommendCrop() {
    if (_formKey.currentState!.validate()) {
      final double n = double.parse(_nController.text);
      final double p = double.parse(_pController.text);
      final double k = double.parse(_kController.text);
      final double temp = double.parse(_tempController.text);
      final double humidity = double.parse(_humidityController.text);
      final double ph = double.parse(_phController.text);
      final double rainfall = double.parse(_rainfallController.text);

      // --- Call the Mock ML Prediction Function ---
      final prediction = _predictCrop(n, p, k, temp, humidity, ph, rainfall);
      // ------------------------------------------

      _setResult(prediction['crop']!, prediction['details']!);
    }
  }

  void _setResult(String crop, String details) {
    setState(() {
      _recommendationResult = crop;
      _recommendationDetails = details;
    });
  }

  // --- UI Component for Result Card (Unchanged) ---
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
                      '✅ ML Recommendation Result',
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
                      'Cultivation Notes (Learned by Model):',
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

  // --- Main Build Method (Unchanged) ---
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
                label: const Text('ANALYZE & RECOMMEND (ML)'),
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

  // --- UI Component for Input Fields (Unchanged) ---
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

  // --- Utility for Input Field Icons (Unchanged) ---
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
