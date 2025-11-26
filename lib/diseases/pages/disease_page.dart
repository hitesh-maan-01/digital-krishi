import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/pytorch_model_service.dart';
import '../models/prediction_result.dart';

class DiseasePage extends StatefulWidget {
  const DiseasePage({super.key});

  @override
  State<DiseasePage> createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage>
    with TickerProviderStateMixin {
  File? _pickedImage;
  PredictionResult? _predictionResult;
  bool _isAnalyzing = false;
  double _scanLinePosition = 0.0;
  String? _errorMessage;

  late AnimationController _scanAnimationController;
  final ImagePicker _picker = ImagePicker();
  final PytorchModelService _modelService = PytorchModelService();

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimationController.addListener(() {
      if (mounted) {
        setState(() {
          _scanLinePosition = _scanAnimationController.value;
        });
      }
    });

    // Initialize model
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      print('🔧 Initializing model...');
      await _modelService.initialize();
      print('✅ Model ready!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI model loaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to initialize model: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load AI model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _modelService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
          _predictionResult = null;
          _errorMessage = null;
        });
        print('📸 Image picked: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_pickedImage == null) {
      print('⚠ No image to analyze');
      return;
    }

    print('🔬 Starting image analysis...');

    setState(() {
      _isAnalyzing = true;
      _predictionResult = null;
      _errorMessage = null;
    });

    _scanAnimationController.repeat(reverse: true);

    try {
      print('📤 Sending image to model...');
      final result = await _modelService.predictImage(_pickedImage!);

      print('📥 Received result: ${result != null ? "Success" : "Null"}');

      if (mounted) {
        setState(() {
          _predictionResult = result;
          _isAnalyzing = false;
          if (result == null) {
            _errorMessage =
                'Could not analyze image. Please try another image.';
          }
        });
      }

      _scanAnimationController.stop();

      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not analyze image. Please try another image.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('✅ Analysis complete!');
        print('🎯 Prediction: ${result.className}');
        print('📊 Confidence: ${result.confidence.toStringAsFixed(2)}%');
      }
    } catch (e, stackTrace) {
      print('❌ Error analyzing image: $e');
      print('📍 Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = 'Error analyzing image: ${e.toString()}';
        });
      }

      _scanAnimationController.stop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detect Disease',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroSection(),
              const SizedBox(height: 24),
              if (_pickedImage == null) _buildActionButtons(),
              if (_pickedImage != null && !_isAnalyzing)
                ElevatedButton.icon(
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Analyze Image'),
                  onPressed: _analyzeImage,
                  style: _buttonStyle(),
                ),
              if (_isAnalyzing) _buildScanningAnimation(),
              const SizedBox(height: 24),
              _buildResultDisplay(),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 240, 253, 244),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 300,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: _pickedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(_pickedImage!, fit: BoxFit.contain),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 48,
                    color: Color.fromARGB(255, 5, 150, 105),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Analyze Your Crop',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 5, 150, 105),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload an image of a leaf or plant to check for common diseases.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
            label: const Text('Upload Image'),
            onPressed: () => _pickImage(ImageSource.gallery),
            style: _buttonStyle(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            label: const Text('Take Photo'),
            onPressed: () => _pickImage(ImageSource.camera),
            style: _buttonStyle(),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningAnimation() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_pickedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(_pickedImage!, fit: BoxFit.contain),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 5, 150, 105),
                  width: 3.0,
                ),
              ),
            ),
          ),
          Positioned(
            top: _scanLinePosition * 268,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Colors.redAccent),
          ),
          const Positioned(
            bottom: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Analyzing...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 5, 150, 105),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      elevation: 4,
    );
  }

  Widget _buildResultDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _predictionResult == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Analysis results will be shown here.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _predictionResult!.isHealthy
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _predictionResult!.isHealthy
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: _predictionResult!.isHealthy
                            ? Colors.green
                            : Colors.orange[700],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _predictionResult!.isHealthy
                                ? 'Healthy Plant'
                                : 'Disease Detected',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _predictionResult!.isHealthy
                                  ? Colors.green
                                  : Colors.orange[800],
                            ),
                          ),
                          Text(
                            '${_predictionResult!.confidence.toStringAsFixed(1)}% confident',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  'Crop Type',
                  _predictionResult!.crop,
                  Icons.agriculture,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Condition',
                  _predictionResult!.condition,
                  Icons.medical_services_outlined,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _predictionResult!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'View All Predictions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 5, 150, 105),
                      ),
                    ),
                    children: _predictionResult!.topPredictions
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final pred = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? Colors.green.withOpacity(0.05)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: index == 0
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.green
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pred.className.replaceAll('_', ' '),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Confidence: ${pred.confidence.toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 5, 150, 105)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
