import 'dart:io' show File; // Safe import for mobile
import 'package:flutter/foundation.dart'; // Gives access to 'kIsWeb'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';

class PhotoUploadBox extends StatefulWidget {
  final Function(XFile? image) onImageSelected;

  const PhotoUploadBox({super.key, required this.onImageSelected});

  @override
  State<PhotoUploadBox> createState() => _PhotoUploadBoxState();
}

class _PhotoUploadBoxState extends State<PhotoUploadBox> {
  XFile? _selectedImage;
  Uint8List? _webImageBytes; // Stores image bytes specifically for Web previews
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      if (kIsWeb) {
        // Read bytes directly so Web can render a smooth preview without crashing
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImage = image;
        });
      }
      widget.onImageSelected(image);
    }
  }

  void _showSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Add Photo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.oliveSecondary,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.terracottaAccent),
                title: const Text(
                  'Take Photo with Camera',
                  style: TextStyle(color: AppColors.oliveSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.terracottaAccent),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.oliveSecondary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Safe helper widget to load the preview on both Mobile and Web
  Widget _buildImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    if (kIsWeb) {
      if (_webImageBytes != null) {
        return Image.memory(
          _webImageBytes!,
          fit: BoxFit.cover,
        );
      }
      return Image.network(
        _selectedImage!.path,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(_selectedImage!.path),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSourceOptions,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage != null ? AppColors.oliveSecondary : Colors.grey.shade300,
            width: _selectedImage != null ? 2 : 1,
          ),
        ),
        child: _selectedImage == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                  SizedBox(height: 8),
                  Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _buildImagePreview(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null;
                          _webImageBytes = null;
                        });
                        widget.onImageSelected(null);
                      },
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}