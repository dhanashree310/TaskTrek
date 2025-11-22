import 'dart:io';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String? avatarPath; // asset path
  File? customImage;  // picked image

  void setAvatar(String path) {
    avatarPath = path;
    customImage = null;
    notifyListeners();
  }

  void setCustomImage(File image) {
    customImage = image;
    avatarPath = null;
    notifyListeners();
  }
}
