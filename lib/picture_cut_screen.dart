import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

// import 'package:santorini_classifier/image_classifier.dart';

class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  Future<(List<File>, List<int>)> cropImage(String imagePath) async {
    // Carregar a imagem original.
    final originalImage = File(imagePath);
    final imageName = imagePath.split('/').last.split('.').first;
    final bytes = await originalImage.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      throw Exception("Error decoding image");
    }

    // Definir os parâmetros do grid.
    const gridDivisions = 5;
    double gridSize = decodedImage.height < decodedImage.width
        ? decodedImage.height.toDouble()
        : decodedImage.width.toDouble();

    gridSize -= gridSize * 0.05;
    final cellSize = (gridSize ~/ gridDivisions);

    final centerX = decodedImage.width ~/ 2;
    final centerY = (decodedImage.height ~/ 2) + 20;

    final left = (centerX - (gridSize ~/ 2)).clamp(0, decodedImage.width);
    final top = (centerY - (gridSize ~/ 2)).clamp(0, decodedImage.height);

    List<File> croppedImages = [];
    List<int> resultImages = [];

    // Dividir a imagem em células e cortá-las.
    for (int row = 0; row < gridDivisions; row++) {
      for (int col = 0; col < gridDivisions; col++) {
        final cropX = left + (col * cellSize) - (cellSize * 0.05);
        final cropY = top + (row * cellSize) - (cellSize * 0.05);

        final croppedImage = img.copyCrop(
          decodedImage,
          x: cropX.toInt(),
          y: cropY.toInt(),
          width: (cellSize * 1.1).toInt(),
          height: (cellSize * 1.1).toInt(),
        );

        final croppedFile =
            File('${originalImage.parent.path}/cropped_${row}_${col}_$imageName.png');
        croppedFile.writeAsBytesSync(img.encodePng(croppedImage));
        croppedImages.add(croppedFile);

        // final resultList = await ImageClassifier().classify(croppedFile);
        // final result = getIndexOfMaxValue(resultList);
        // resultImages.add(result);
      }
    }

    return (croppedImages, resultImages);
  }

  int getIndexOfMaxValue(List<num> list) {
    if (list.isEmpty) {
      throw Exception("The list is empty");
    }

    int maxIndex = 0;
    num maxValue = list[0];

    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Classification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.blue,
      body: FutureBuilder<(List<File>, List<int>)>(
        future: cropImage(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final croppedImages = snapshot.data!.$1;
            final results = snapshot.data!.$2;
            return Center(
                child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, crossAxisSpacing: 1, mainAxisSpacing: 1),
              itemCount: croppedImages.length,
              itemBuilder: (context, index) {
                return Stack(children: [
                  Image.file(croppedImages[index]),
                  // Center(
                  //     child: Text(
                  //   resultToText(results[index]),
                  //   style: const TextStyle(
                  //       fontSize: 30,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.white),
                  // )),
                ]);
              },
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  String resultToText(int result) {
    switch (result) {
      case 0:
        return '0A';
      case 1:
        return '0C';
      case 2:
        return '0N';
      case 3:
        return '1A';
      case 4:
        return '1C';
      case 5:
        return '1N';
      case 6:
        return '2A';
      case 7:
        return '2C';
      case 8:
        return '2N';
      case 9:
        return '3A';
      case 10:
        return '3C';
      case 11:
        return '3N';
      case 12:
        return '4N';
      default:
        return '-';
    }
  }
}
