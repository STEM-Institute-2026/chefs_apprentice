import 'package:flutter/foundation.dart'; // Gives us access to 'kIsWeb'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';

class PhotoUploadBox extends StatefulWidget {
  // Callback function to pass the selected image file up to the parent screen
  final Function(XFile? image) onImageSelected;

  const PhotoUploadBox({super.key, required this.onImageSelected});

  @override
  State<PhotoUploadBox> createState() => _PhotoUploadBoxState();
}

class _PhotoUploadBoxState extends State<PhotoUploadBox> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Launches the native phone camera or photo gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 80, // Compresses image to save memory
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      widget.onImageSelected(image); // Rings the parent and hands over the photo
    }
  }

  // Slides up the menu asking user to choose between Camera or Gallery
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
              const Text('Add Photo', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.oliveSecondary)),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.terracottaAccent),
                title: const Text('Take Photo with Camera', style: TextStyle(color: AppColors.oliveSecondary)),
                onTap: () {
                  Navigator.pop(context); // Closes bottom menu
                  _pickImage(ImageSource.camera); // opens camera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.terracottaAccent),
                title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.oliveSecondary)),
                onTap: () {
                  Navigator.pop(context); // Closes bottom menu
                  _pickImage(ImageSource.gallery); // opens gallery
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSourceOptions,
      child: Container(
        height: 600,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage != null ? AppColors.oliveSecondary : Colors.grey.shade300, // if image then green border and bigger width
            width: _selectedImage != null ? 2 : 1,
          ),
        ),
        child: _selectedImage == null
            // STATE A: No photo selected yet
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 32),
                  SizedBox(height: 8),
                  Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                ],
              )
            // STATE B: Photo captured/selected (Shows preview & delete button)
            : Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: kIsWeb
                      ? Image.network(
                          _selectedImage!.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = null; // Clear image locally
                        });
                        widget.onImageSelected(null); // Tell parent photo was removed
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