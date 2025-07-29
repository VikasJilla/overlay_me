import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../widgets/permission_wrapper.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile? profile;

  const ProfileEditScreen({super.key, this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _profilePhotoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    // Proactively request permission when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestPhotoPermission(context);
    });
  }

  void _loadProfileData() {
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name ?? '';
      _businessController.text = widget.profile!.businessDetails ?? '';
      _phoneController.text = widget.profile!.phoneNumber ?? '';
      _profilePhotoPath = widget.profile!.profilePhotoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionService.requestPhotoPermission(context);
    if (!hasPermission) {
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profilePhotoPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _businessController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = UserProfile(
        name: _nameController.text,
        businessDetails: _businessController.text,
        phoneNumber: _phoneController.text,
        profilePhotoPath: _profilePhotoPath,
      );

      await StorageService.saveUserProfile(profile);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Photo Section
            PermissionWrapper(
              permissionMessage: 'Photo Permission Required',
              onPermissionGranted: () {
                // Permission granted, user can now interact with photo picker
              },
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: ClipOval(
                        child: _profilePhotoPath != null
                            ? Image.file(
                                File(_profilePhotoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.add_a_photo, size: 60, color: Colors.grey),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(onPressed: _pickImage, child: const Text('Change Photo')),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form Fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _businessController,
              decoration: const InputDecoration(
                labelText: 'Business/Profession',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
