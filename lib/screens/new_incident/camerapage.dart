import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController; // Use late initialization

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], // Use the first available camera
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onCapturePressed() async {
    try {
      final XFile capturedImage = await _cameraController.takePicture();
      Navigator.pop(context, capturedImage);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container(); // You might want to show a loading indicator here
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Page'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _onCapturePressed,
                child: Text('Capture'),
              ),
            ),
          ),
        ],
      ),
      // Add your camera controls or other UI elements here
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
