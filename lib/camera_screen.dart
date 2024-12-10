import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:santorini_classifier/grip_painter.dart';
// import 'package:santorini_classifier/src/picture_cut_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  static const routeName = '/camera';

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    // Inicializar o controlador da câmera.
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    // Inicializar a câmera.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Liberar o controlador da câmera quando não for mais necessário.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Take a Picture of your Board',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Se a câmera foi inicializada, exiba a visualização.
            return Stack(
              children: [
                CameraPreview(_controller),
                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: GridPainter(),
                ),
              ],
            );
          } else {
            // Caso contrário, exiba um indicador de carregamento.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Aguarde até que a câmera esteja inicializada.
            await _initializeControllerFuture;

            // Tire a foto e armazene-a em um arquivo temporário.
            final image = await _controller.takePicture();

            // Navegue para outra tela para exibir a foto.
            if (!mounted) return;
            // await Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => DisplayPictureScreen(
            //       imagePath: image.path,
            //     ),
            //   ),
            // );
          } catch (e) {
            // Se ocorrer um erro, exiba-o no console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
