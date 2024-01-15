/*import 'package:camera/camera.dart';
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
*/

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController; // Use late initialization
  bool _imageCaptured = false;
  late XFile _capturedImage;

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
      _capturedImage = await _cameraController.takePicture();
      setState(() {
        _imageCaptured = true;
      });
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _deleteImageFromStorage(String imageURL) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = await storage.refFromURL(imageURL);
      await storageRef.delete();
      print('Image deleted successfully!');
    } catch (e) {
      print('Error deleting image: $e');
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
                  onPressed: () async {
                    await _onCapturePressed();
                    if (_imageCaptured) {
                      /*String? imageURL =
                          await _uploadImage(File(_capturedImage.path));*/
                      Navigator.pop(context, _capturedImage.path);
                    }
                    else {
                      Navigator.pop(context, '');
                    }
                  },
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

  Future<String?> uploadImage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = storage.ref().child('images/$fileName.jpg');
        UploadTask task = storageRef.putFile(imageFile);

        // Wait for the upload to complete
        await task;

        // Retrieve the download URL
        String downloadURL = await storageRef.getDownloadURL();

        print('Image uploaded successfully!');
        return downloadURL;
      }
     catch (e) {
      print('Error uploading image: $e');
      return null; // Return null in case of an error
    }
  }