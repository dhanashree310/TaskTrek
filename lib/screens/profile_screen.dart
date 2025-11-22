import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  User? user;
  TextEditingController _nameController = TextEditingController();

  final List<String> avatars = [
    'assets/images/boy.jpg',
    'assets/images/girl.png',
  ];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _nameController.text = user?.displayName ?? '';
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('avatarPath');
    if (savedAvatar != null && savedAvatar.isNotEmpty) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAvatar(savedAvatar);
    }
  }

  Future<void> _saveAvatarLocally(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatarPath', path);
  }

  Future<void> pickProfileImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      File imageFile = File(picked.path);
      Provider.of<ProfileProvider>(context, listen: false)
          .setCustomImage(imageFile);
      _saveAvatarLocally('');
      setState(() {}); // refresh UI
    }
  }

  void selectAvatar(String path) {
    Provider.of<ProfileProvider>(context, listen: false).setAvatar(path);
    _saveAvatarLocally(path);
    setState(() {}); // refresh UI
  }

  Future<void> saveProfileChanges() async {
    try {
      await user?.updateDisplayName(_nameController.text.trim());
      await user?.reload();
      setState(() {
        user = _auth.currentUser;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    ImageProvider displayImage = profileProvider.customImage != null
        ? FileImage(profileProvider.customImage!)
        : profileProvider.avatarPath != null
            ? AssetImage(profileProvider.avatarPath!)
            : AssetImage('assets/images/default.png');

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: displayImage,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: pickProfileImage,
              child: Text("Update Profile Photo"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Or choose an avatar:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: avatars.map((avatar) {
                  bool selected = profileProvider.avatarPath == avatar;
                  return GestureDetector(
                    onTap: () => selectAvatar(avatar),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          avatar,
                          width: selected ? 90 : 80,
                          height: selected ? 90 : 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: saveProfileChanges,
              child: Text("Save Changes"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
