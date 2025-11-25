import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DiseasePage extends StatefulWidget {
  const DiseasePage({super.key});

  @override
  State<DiseasePage> createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage>
    with TickerProviderStateMixin {
  // State variables for the image and analysis results
  File? _pickedImage;
  String? _detectedDisease;
  double? _confidenceScore;
  String? _diseaseDescription;
  bool _isAnalyzing = false;
  double _scanLinePosition = 0.0;

  // Animation controller for the scanning effect
  late AnimationController _scanAnimationController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller for the scanning effect
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Set up the animation listener
    _scanAnimationController.addListener(() {
      setState(() {
        _scanLinePosition = _scanAnimationController.value;
      });
    });
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _detectedDisease = null;
        _confidenceScore = null;
        _diseaseDescription = null;
      });
    }
  }

  // Function to perform the analysis process without dummy data
  void _analyzeImage() {
    setState(() {
      _isAnalyzing = true;
    });

    _scanAnimationController.repeat(
      reverse: true,
    ); // Start the scanning animation

    // Stops the animation without updating the results
    Future.delayed(const Duration(seconds: 20), () {
      _scanAnimationController.stop(); // Stop the animation
      setState(() {
        _isAnalyzing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detect Disease',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
        elevation: 1.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
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
      height: 300, // Fixed height for a larger image display
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: _pickedImage != null
            ? Image.file(
                _pickedImage!,
                fit: BoxFit.contain, // Ensures the whole image is visible
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
    return SizedBox(
      height: 300, // Match the height of the hero section
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_pickedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(_pickedImage!, fit: BoxFit.contain),
            ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
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
            top: _scanLinePosition * 300, // Adjusted for new container size
            child: Container(
              height: 3,
              width: double.infinity,
              color: Colors.redAccent,
              alignment: Alignment.center,
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
        color: const Color.fromARGB(255, 240, 253, 244),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: _detectedDisease == null
          ? const Center(
              child: Text(
                'Analysis results will be shown here.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analysis Result',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 5, 150, 105),
                  ),
                ),
                const Divider(height: 20),
                Text(
                  _detectedDisease!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confidence: $_confidenceScore%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _diseaseDescription!,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
    );
  }
}
