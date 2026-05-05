import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: LuxorColors.primary, size: 64),
              const SizedBox(height: 16),
              const Text('Cámara', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickImage(source: ImageSource.camera);
                  if (context.mounted) Navigator.of(context).pop(file?.path);
                },
                icon: const Icon(Icons.camera),
                label: const Text('Tomar foto'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final file = await picker.pickVideo(source: ImageSource.camera);
                  if (context.mounted) Navigator.of(context).pop(file?.path);
                },
                icon: const Icon(Icons.videocam),
                label: const Text('Grabar video'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}