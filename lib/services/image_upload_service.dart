// lib/services/image_upload_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  // Replace with your actual key from api.imgbb.com
  static const String _imgBbApiKey = '868b415993848efe4494dadd693a390f';

  static Future<String?> uploadToImgBB(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey'),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'] as String;
      }
    } catch (e) {
      debugPrint('ImgBB Exception: $e'); // Optional: Keep only exception logging
    }
    return null;
  }
}