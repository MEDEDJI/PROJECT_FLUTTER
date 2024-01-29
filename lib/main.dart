import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'text_recognize.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('fr','FR'),
      title: 'Text Recognition with Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

final textRecognizer = TextRecognizer();

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isCameraPermissionGranted = false;
  late final Future<void> _future;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _initializeApplication();
  }

  // Initialize the application, request camera permission, and initialize the camera if permission is granted
  Future<void> _initializeApplication() async {
    await _requestCameraPermission();
    if (_isCameraPermissionGranted) {
      await _initializeCamera();
    }
  }

  // Request permission to access the camera
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status == PermissionStatus.granted;
    });
  }

  // Initialize the camera by selecting the first available rear camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _initializeCameraController(cameras);
  }

  // Initialize the camera controller with the first available rear camera
  void _initializeCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null || cameras.isEmpty) {
      return;
    }

    // Select the first rear camera.
    final CameraDescription camera = cameras.firstWhere(
      (current) => current.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  // Start the camera if initialized
  Future<void> _startCamera() async {
    if (_cameraController != null && !_cameraController!.value.isInitialized) {
      await _cameraController!.initialize();
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      (_cameraController!.description);
    }
  }

  // Stop the camera
  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController!.dispose();
    }
  }

  // Observe the change in the application's state and act accordingly (stop or start the camera)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

  // Release resources when the screen is closed
  @override
  void dispose() {
    _stopCamera();
    textRecognizer.close();
    super.dispose();
    setState(() {});
  }

  // Get an image from the gallery
  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // ignore: use_build_context_synchronously
      final navigator = Navigator.of(context);
      await navigator.pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              TexteRecup(text: recognizedText.text),
        ),
      );
    } else {
      // ignore: avoid_print
      print('No image are selected.');
    }
  }


  // Scan an image using the camera
  Future<void> _scanImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator.pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              TexteRecup(text: recognizedText.text),
        ),
      );
    } catch (e) {
      // Show a notification in case of an error during text recognition
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while scanning the text"),
        ),
      );
    }
  }

  // Build the user interface based on the application state
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            // Show the camera preview if permission is granted
            if (_isCameraPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initializeCameraController(snapshot.data!);

                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text('Text Recup'),
              ),
              backgroundColor:
                  _isCameraPermissionGranted ? Colors.transparent : null,
              body: _isCameraPermissionGranted
                  ? Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Button to scan an image using the camera
                                FloatingActionButton(
                                  onPressed: _scanImage,
                                  child: const Text("Scanner"),
                                ),
                                // Button to get an image from the gallery
                                FloatingActionButton(
                                  onPressed: _getImage,
                                  child: const Text("Galerie"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: const Text(
                          "Camera permission denied",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
