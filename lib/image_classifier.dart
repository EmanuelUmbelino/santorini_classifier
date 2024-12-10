import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart'; 

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

  Future<List<double>> classify(File image) async {
    final imageBytes = await image.readAsBytes();

    final imageData = _preprocessImage(imageBytes);
    final inputShape = [1, 3, 124, 124];

    final result = await _channel.invokeMethod('classify', {
      'imageData': imageData,
      'inputShape': inputShape,
    });
    return List<double>.from(result);
  }

  List<double> _preprocessImage(Uint8List imageBytes) {
    // Adicione lógica para redimensionar a imagem e normalizar
    Image? image = decodeImage(imageBytes);
    if (image == null) throw Exception('Falha ao decodificar a imagem');

    // Redimensionar para 124x124
    Image resizedImage = copyResize(image, width: 124, height: 124);

    // Normalizar os valores para a faixa [0, 1]
    List<double> normalizedImage = [];
    for (int y = 0; y < 124; y++) {
      for (int x = 0; x < 124; x++) {
        Pixel pixel = resizedImage.getPixel(x, y);

        // Adicionar ao array
        normalizedImage.addAll([
            pixel.rNormalized.toDouble(), // Canal R
            pixel.gNormalized.toDouble(), // Canal G
            pixel.bNormalized.toDouble() // Canal B
          ]);
      }
    }

    return normalizedImage; // Retorna como uma lista unidimensional
  }
}
