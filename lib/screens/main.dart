import 'package:camera/camera.dart';
import 'package:easytax/screens/dashboard.dart';
import 'package:easytax/screens/image_processing.dart';
import 'package:easytax/screens/taxinfo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late CameraController _controller;
  Color borderColor = Colors.transparent;
  final borderAnimationDuration = const Duration(milliseconds: 500);

  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setupCameras());
  }

  Future<void> setupCameras() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras.first, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> takePicture() async {
    try {
      await _initializeControllerFuture;

      setState(() {
        borderColor = Colors.red;
      });

      final imageFile = await _controller.takePicture();

      await Future.delayed(borderAnimationDuration ~/ 2);
      setState(() {
        borderColor = Colors.transparent;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageProcessingScreen(imageTaken: imageFile)),
      );
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ImageProcessingScreen(imageTaken: pickedFile)),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AnimatedContainer(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: borderColor,
                            width: 5.0,
                          ),
                        ),
                        duration: borderAnimationDuration,
                        child: CameraPreview(_controller),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _pickImageFromGallery,
              child: const Icon(Icons.photo_library),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashBoardScreen(),
                    ),
                  );
                },
                tooltip: 'Dashboard',
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.document_scanner_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TaxInformationScreen(),
                    ),
                  );
                },
                tooltip: 'Tax Docs',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: takePicture,
        shape: const CircleBorder(),
        heroTag: "Camera Button",
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
