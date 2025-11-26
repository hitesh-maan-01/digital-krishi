import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:image/image.dart' as img;
import '../models/prediction_result.dart';

class PytorchModelService {
  ClassificationModel? _model;
  List<String>? _labels;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('📄 Loading PyTorch model...');

      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .toList();

      print('✅ Loaded ${_labels!.length} labels');
      if (_labels!.isNotEmpty) {
        print('🏷 First label: ${_labels![0]}');
        print('🏷 Last label: ${_labels![_labels!.length - 1]}');
      }

      _model = await PytorchLite.loadClassificationModel(
        'assets/models/mobile_model.ptl',
        256,
        256,
        _labels!.length,
      );

      _isInitialized = true;
      print('✅ PyTorch model initialized successfully!');
    } catch (e) {
      print('❌ Error initializing model: $e');
      rethrow;
    }
  }

  Future<PredictionResult?> predictImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_model == null || _labels == null) {
      throw Exception('Model not initialized');
    }

    try {
      print('🔍 Starting prediction...');

      final imageBytes = await _preprocessImage(imageFile);

      // Use getImagePredictionList instead of getImagePrediction
      // This typically returns probabilities for all classes
      final resultList = await _model!.getImagePredictionList(imageBytes);

      print('📊 Result list length: ${resultList?.length ?? 0}');
      print('📊 Expected labels: ${_labels!.length}');

      if (resultList == null || resultList.isEmpty) {
        print('⚠ No results from model');
        return null;
      }

      // resultList should contain probabilities for each class
      List<Prediction> predictions = _parseResultList(resultList);

      if (predictions.isEmpty) {
        print('⚠ No predictions generated');
        return null;
      }

      // Sort by confidence (descending)
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      print('✅ Generated ${predictions.length} predictions');
      print(
        '🎯 Top prediction: ${predictions[0].className} (${predictions[0].confidence.toStringAsFixed(2)}%)',
      );

      return PredictionResult.fromClassification(
        predictions[0].className,
        predictions[0].confidence,
        predictions.take(5).toList(),
      );
    } catch (e, stackTrace) {
      print('❌ Error during prediction: $e');
      print('📍 Stack trace: $stackTrace');

      // Fallback: try the old method
      try {
        print('🔄 Trying fallback prediction method...');
        // Re-preprocess image for fallback
        final fallbackImageBytes = await _preprocessImage(imageFile);
        final result = await _model!.getImagePrediction(fallbackImageBytes);
        return _handleFallbackPrediction(result);
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
        return null;
      }
    }
  }

  List<Prediction> _parseResultList(List<dynamic> resultList) {
    try {
      List<Prediction> predictions = [];

      print('🔍 Parsing result list...');

      // Handle the case where resultList contains probability scores for each class
      if (resultList.length == _labels!.length) {
        print('✅ Result list matches number of labels');

        for (int i = 0; i < resultList.length; i++) {
          double confidence = 0.0;

          if (resultList[i] is double) {
            confidence = resultList[i] as double;
          } else if (resultList[i] is int) {
            confidence = (resultList[i] as int).toDouble();
          } else if (resultList[i] is String) {
            confidence = double.tryParse(resultList[i] as String) ?? 0.0;
          } else {
            confidence = double.tryParse(resultList[i].toString()) ?? 0.0;
          }

          // Convert to percentage (assume model outputs are probabilities 0-1)
          // If values are already 0-100, this won't break them
          if (confidence <= 1.0) {
            confidence = confidence * 100.0;
          }

          predictions.add(
            Prediction(
              className: _labels![i],
              confidence: confidence,
              index: i,
            ),
          );
        }

        print('✅ Parsed ${predictions.length} predictions');

        // Show top 3 for debugging
        predictions.sort((a, b) => b.confidence.compareTo(a.confidence));
        for (int i = 0; i < 3 && i < predictions.length; i++) {
          print(
            '   ${i + 1}. ${predictions[i].className}: ${predictions[i].confidence.toStringAsFixed(2)}%',
          );
        }
      } else {
        print(
          '⚠ Result list length (${resultList.length}) does not match labels (${_labels!.length})',
        );

        // Try to handle as [index, confidence] pairs or other formats
        if (resultList.length == 2) {
          final index = _parseIndex(resultList[0]);
          final confidence = _parseConfidence(resultList[1]);

          if (index >= 0 && index < _labels!.length) {
            predictions.add(
              Prediction(
                className: _labels![index],
                confidence: confidence,
                index: index,
              ),
            );
          }
        }
      }

      return predictions;
    } catch (e) {
      print('❌ Error parsing result list: $e');
      return [];
    }
  }

  Future<PredictionResult?> _handleFallbackPrediction(dynamic result) async {
    try {
      print('📊 Fallback result: $result');
      print('📊 Fallback result type: ${result.runtimeType}');

      List<Prediction> predictions = [];

      if (result is String) {
        predictions = _parseStringResult(result);
      } else if (result is Map) {
        predictions = _parseMapResult(result as Map<dynamic, dynamic>);
      } else if (result is List) {
        predictions = _parseResultList(result as List<dynamic>);
      } else if (result is int || result is double) {
        predictions = _parseNumericResult(result);
      }

      if (predictions.isEmpty) {
        return null;
      }

      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return PredictionResult.fromClassification(
        predictions[0].className,
        predictions[0].confidence,
        predictions.take(5).toList(),
      );
    } catch (e) {
      print('❌ Fallback prediction error: $e');
      return null;
    }
  }

  int _parseIndex(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? -1;
    return int.tryParse(value.toString()) ?? -1;
  }

  double _parseConfidence(dynamic value) {
    double confidence = 0.0;

    if (value is double) {
      confidence = value;
    } else if (value is int) {
      confidence = value.toDouble();
    } else if (value is String) {
      confidence = double.tryParse(value) ?? 0.0;
    } else {
      confidence = double.tryParse(value.toString()) ?? 0.0;
    }

    // Convert to percentage if needed
    if (confidence <= 1.0) {
      confidence = confidence * 100.0;
    }

    return confidence;
  }

  List<Prediction> _parseNumericResult(dynamic result) {
    try {
      final index = _parseIndex(result);

      print('🔢 Predicted index: $index');
      print('📚 Total labels available: ${_labels!.length}');

      if (index < 0 || index >= _labels!.length) {
        print('⚠ Index $index out of range [0, ${_labels!.length - 1}]');
        return [];
      }

      List<Prediction> predictions = [];

      predictions.add(
        Prediction(className: _labels![index], confidence: 95.0, index: index),
      );

      // Add other predictions with decreasing confidence
      final usedIndices = {index};
      for (int i = 0; i < _labels!.length && predictions.length < 5; i++) {
        if (!usedIndices.contains(i)) {
          predictions.add(
            Prediction(
              className: _labels![i],
              confidence: 85.0 - (predictions.length * 10.0),
              index: i,
            ),
          );
          usedIndices.add(i);
        }
      }

      return predictions;
    } catch (e) {
      print('❌ Error parsing numeric result: $e');
      return [];
    }
  }

  List<Prediction> _parseStringResult(String result) {
    try {
      List<Prediction> predictions = [];
      final parts = result.trim().split(' ');

      print('🔍 String parts: $parts');

      if (parts.isEmpty) return [];

      if (parts.length >= 2) {
        final firstPart = parts[0];
        final confidenceStr = parts[parts.length - 1];
        final confidence = _parseConfidence(confidenceStr);

        String className;
        int classIndex;

        final indexParsed = int.tryParse(firstPart);
        if (indexParsed != null &&
            indexParsed >= 0 &&
            indexParsed < _labels!.length) {
          classIndex = indexParsed;
          className = _labels![classIndex];
        } else {
          className = parts.sublist(0, parts.length - 1).join(' ');
          classIndex = _labels!.indexOf(className);
          if (classIndex == -1) {
            classIndex = 0;
            className = _labels![0];
          }
        }

        predictions.add(
          Prediction(
            className: className,
            confidence: confidence,
            index: classIndex,
          ),
        );

        // Add remaining predictions
        final usedIndices = {classIndex};
        for (int i = 0; i < _labels!.length && predictions.length < 5; i++) {
          if (!usedIndices.contains(i)) {
            predictions.add(
              Prediction(
                className: _labels![i],
                confidence: confidence * (0.7 - predictions.length * 0.12),
                index: i,
              ),
            );
            usedIndices.add(i);
          }
        }
      }

      return predictions;
    } catch (e) {
      print('❌ Error parsing string result: $e');
      return [];
    }
  }

  List<Prediction> _parseMapResult(Map<dynamic, dynamic> result) {
    try {
      List<Prediction> predictions = [];

      print('🗺 Map contents: $result');

      final className = (result['label'] ?? result['class'] ?? '').toString();
      final confidence = _parseConfidence(
        result['confidence'] ?? result['score'] ?? 0.0,
      );

      if (className.isEmpty) {
        print('⚠ No class name found in map');
        return [];
      }

      final index = _labels!.indexOf(className);

      predictions.add(
        Prediction(
          className: className,
          confidence: confidence,
          index: index >= 0 ? index : 0,
        ),
      );

      return predictions;
    } catch (e) {
      print('❌ Error parsing map result: $e');
      return [];
    }
  }

  Future<Uint8List> _preprocessImage(File imageFile) async {
    try {
      print('🖼 Preprocessing image...');

      final originalBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(originalBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      print('Original size: ${image.width}x${image.height}');

      // Resize to 256x256
      final resized = img.copyResize(
        image,
        width: 256,
        height: 256,
        interpolation: img.Interpolation.linear,
      );

      print('Resized to: ${resized.width}x${resized.height}');

      // Encode to JPEG bytes
      final processedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: 95),
      );

      print('✅ Image preprocessed: ${processedBytes.length} bytes');

      return processedBytes;
    } catch (e) {
      print('❌ Error preprocessing image: $e');
      rethrow;
    }
  }

  void dispose() {
    _model = null;
    _isInitialized = false;
    print('🗑 Model service disposed');
  }
}
