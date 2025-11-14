// lib/features/camera/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/services/ai_service.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final AIService _aiService = AIService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      await _aiService.initialize();
      print('✅ Services IA initialisés pour la caméra');
    } catch (e) {
      print('⚠️ Erreur initialisation IA: $e');
    }
  }

  Future<void> _initializeCamera() async {
    // ⭐ AJOUTEZ CETTE VÉRIFICATION :
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    
    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _controller = CameraController(cameras.first, ResolutionPreset.high);
        _initializeControllerFuture = _controller!.initialize();
        setState(() {});
      }
    } else {
       // Gérer le cas où la permission est refusée
       print('❌ Permission de caméra refusée');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text('Accès à la caméra refusé. Veuillez l\'activer dans les paramètres.'),
             backgroundColor: Colors.orange,
           ),
         );
       }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _aiService.dispose(); // 🧹 Libérer les ressources IA
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final imageFile = File(image.path);
        
        // Process with AI - identifyInfestation retourne Map<String, dynamic>
        final result = await _aiService.identifyInfestation(imageFile);

        if (mounted && context.mounted) {
          // Passer le résultat au format Map
          context.push('/detection-result', extra: result);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final imageFile = File(image.path);

      // Process with AI - identifyInfestation retourne Map<String, dynamic>
      final result = await _aiService.identifyInfestation(imageFile);

      if (mounted && context.mounted) {
        // Naviguer avec le résultat au format Map
        context.push('/detection-result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'analyse: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scanner un insecte',
            style: TextStyle(color: Colors.white)),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 64),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isProcessing ? Colors.grey : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _isProcessing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black),
                                )
                              : const Icon(Icons.camera_alt,
                                  size: 32, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        onPressed: _isProcessing ? null : _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library,
                            color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
