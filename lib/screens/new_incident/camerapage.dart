// camera.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    if (!mounted)
      return; // Ensure the state is still mounted before setting state
    setState(
        () {}); // Trigger a rebuild to update the UI after the camera is initialized
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Center(
        child: CameraPreview(_cameraController),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? image = await _cameraController.takePicture();

          if (image != null) {
            Navigator.pop(context,
                image); // Pass the captured image back to the previous page
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
