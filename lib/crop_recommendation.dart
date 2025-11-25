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
      //final double rainfall = double.parse(_rainfallController.text);

      // Rule-based logic remains the same for the SIH prototype
      if (temp >= 20 &&
          temp <= 25 &&
          humidity >= 60 &&
          humidity <= 80 &&
          ph >= 6.0 &&
          ph <= 7.0) {
        if (n > 80 && p < 60 && k < 40) {
          _setResult(
            'Rice',
            'Ideal NPK for rice is high N, low P and K. Requires high humidity and warm weather.',
          );
        } else if (n >= 50 &&
            n <= 100 &&
            p >= 40 &&
            p <= 80 &&
            k >= 40 &&
            k <= 60) {
          _setResult(
            'Wheat',
            'Wheat prefers a moderate NPK balance and cool climate. High rainfall is not suitable.',
          );
        } else if (n >= 80 && p >= 40 && k >= 40) {
          _setResult(
            'Maize',
            'Maize requires high levels of all nutrients. It is adaptable to various conditions but prefers high N.',
          );
        } else {
          _setResult(
            'General Vegetable Crop',
            'The conditions are suitable for a general vegetable crop. Consider checking specific crop requirements.',
          );
        }
      } else {
        _setResult(
          'No Specific Recommendation',
          'The entered conditions do not closely match any of the crops in our database. Please check your values.',
        );
      }
    }
  }

  void _setResult(String crop, String details) {
    setState(() {
      _recommendationResult = crop;
      _recommendationDetails = details;
    });
  }

  Widget _buildResultCard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _recommendationResult != null
          ? Card(
              key: const ValueKey<int>(1), // Unique key for AnimatedSwitcher
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Crop: 🌱 $_recommendationResult',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Cultivation Notes:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recommendationDetails!,
                      style: const TextStyle(fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Crop Recommendation'),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Enter your soil and environmental data to get a crop recommendation.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildInputField('Nitrogen (N) Ratio', _nController),
              _buildInputField('Phosphorus (P) Ratio', _pController),
              _buildInputField('Potassium (K) Ratio', _kController),
              _buildInputField('Temperature (°C)', _tempController),
              _buildInputField('Humidity (%)', _humidityController),
              _buildInputField('pH Value', _phController),
              _buildInputField('Rainfall (mm)', _rainfallController),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _recommendCrop,
                icon: const Icon(Icons.search),
                label: const Text('Get Recommendation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 150, 105),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: _getIconForLabel(label),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a value for $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  Icon _getIconForLabel(String label) {
    switch (label) {
      case 'Nitrogen (N) Ratio':
        return const Icon(Icons.science);
      case 'Phosphorus (P) Ratio':
        return const Icon(Icons.science);
      case 'Potassium (K) Ratio':
        return const Icon(Icons.science);
      case 'Temperature (°C)':
        return const Icon(Icons.thermostat);
      case 'Humidity (%)':
        return const Icon(Icons.cloud_queue);
      case 'pH Value':
        return const Icon(Icons.grain);
      case 'Rainfall (mm)':
        return const Icon(Icons.umbrella);
      default:
        return const Icon(Icons.grass);
    }
  }
}
