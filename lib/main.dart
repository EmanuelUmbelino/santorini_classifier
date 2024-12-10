import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home.dart';
import 'camera_screen.dart';
import 'image_classifier.dart';

void main() async {
  // Garantir que a inicialização dos widgets foi concluída.
  WidgetsFlutterBinding.ensureInitialized();

  // Obter as câmeras disponíveis no dispositivo.
  final cameras = await availableCameras();

  // Selecionar a primeira câmera disponível.
  final firstCamera = cameras.first;

  final imageClassifier = ImageClassifier();

  await imageClassifier.loadModel();

  runApp(MainApp(camera: firstCamera));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case CameraScreen.routeName:
                return CameraScreen(camera: camera);
              case HomeView.routeName:
              default:
                return HomeView();
            }
          },
        );
      },
    );
  }
}
