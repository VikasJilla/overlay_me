import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../widgets/permission_wrapper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  int _currentPage = 0;
  String? _profilePhotoPath;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
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

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (_profilePhotoPath == null ||
        _nameController.text.isEmpty ||
        _businessController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final profile = UserProfile(
      name: _nameController.text,
      businessDetails: _businessController.text,
      phoneNumber: _phoneController.text,
      profilePhotoPath: _profilePhotoPath,
    );

    await StorageService.saveUserProfile(profile);
    await StorageService.markOnboardingCompleted();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 4,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [_buildPhotoPage(), _buildNamePage(), _buildBusinessPage(), _buildPhonePage()],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(onPressed: _previousPage, child: const Text('Back'))
                  else
                    const SizedBox(width: 80),

                  ElevatedButton(onPressed: _nextPage, child: Text(_currentPage == 3 ? 'Complete' : 'Next')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_camera, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('Add Your Profile Photo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Upload a clear photo of yourself that will be used in your overlays',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          PermissionWrapper(
            permissionMessage: 'Photo Permission Required',
            onPermissionGranted: () {
              // Permission granted, user can now interact with photo picker
            },
            onPermissionDenied: () {
              // Show a message that photo is required to continue
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo permission is required to continue with setup'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: _profilePhotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(73),
                            child: Image.file(File(_profilePhotoPath!), fit: BoxFit.cover),
                          )
                        : const Icon(Icons.add_a_photo, size: 50, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(onPressed: _pickImage, child: const Text('Choose Photo')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('What\'s Your Name?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Enter your full name as you\'d like it to appear',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessPage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('Business Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Tell us about your business or profession',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _businessController,
            decoration: const InputDecoration(
              labelText: 'Business/Profession',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_outlined),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildPhonePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('Contact Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Add your phone number for contact purposes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}
