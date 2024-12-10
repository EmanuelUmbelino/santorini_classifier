import 'package:flutter/services.dart';

class ImageClassifier {
  static const MethodChannel _channel = MethodChannel('pytorch_classifier');

  Future<void> loadModel() async {
    try {
      final e = await _channel.invokeMethod('loadModel');
      print('CODE - Model loaded successful: $e');
    } catch (e) {
      print('Error on load model: $e');
    }
  }
}
