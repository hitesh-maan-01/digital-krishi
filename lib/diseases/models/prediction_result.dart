class PredictionResult {
  final String className;
  final double confidence;
  final String crop;
  final String condition;
  final bool isHealthy;
  final List<Prediction> topPredictions;

  PredictionResult({
    required this.className,
    required this.confidence,
    required this.crop,
    required this.condition,
    required this.isHealthy,
    required this.topPredictions,
  });

  factory PredictionResult.fromClassification(
    String className,
    double confidence,
    List<Prediction> allPredictions,
  ) {
    final parts = className.split('_');
    final crop = parts.isNotEmpty ? parts[0] : 'Unknown';
    final condition = parts.length > 1
        ? parts.sublist(1).join(' ').replaceAll('_', ' ')
        : 'Unknown';
    final isHealthy = className.toLowerCase().contains('healthy');

    return PredictionResult(
      className: className,
      confidence: confidence,
      crop: _formatText(crop),
      condition: _formatText(condition),
      isHealthy: isHealthy,
      topPredictions: allPredictions,
    );
  }

  static String _formatText(String text) {
    return text
        .split('_')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');
  }

  String get description {
    if (isHealthy) {
      return 'The $crop plant appears to be healthy with no signs of disease detected.';
    } else {
      return 'Disease detected: $condition. Please consult with an agricultural expert for treatment recommendations.';
    }
  }
}

class Prediction {
  final String className;
  final double confidence;
  final int index;

  Prediction({
    required this.className,
    required this.confidence,
    required this.index,
  });
}
