import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await StorageService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Me'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  if (_userProfile?.profilePhotoPath != null)
                    CircleAvatar(radius: 40, backgroundImage: FileImage(File(_userProfile!.profilePhotoPath!)))
                  else
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    'Welcome back, ${_userProfile?.name ?? 'User'}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _userProfile?.businessDetails ?? 'Ready to create overlays?',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Main action buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionCard(
                    icon: Icons.photo_library,
                    title: 'Create Photo Overlay',
                    subtitle: 'Upload a photo and add your profile overlay',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.of(context).pushNamed('/photo-editing');
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildActionCard(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your profile information',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildActionCard(
                    icon: Icons.help_outline,
                    title: 'How It Works',
                    subtitle: 'Learn how to create amazing overlays',
                    color: Colors.orange,
                    onTap: () {
                      _showHowItWorks();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowItWorks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How It Works'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Upload a photo from your gallery'),
            SizedBox(height: 10),
            Text('2. Choose an overlay style:'),
            SizedBox(height: 5),
            Text('   • Circular profile photo overlay'),
            Text('   • Profile details with background'),
            SizedBox(height: 10),
            Text('3. Customize position, shape, and colors'),
            SizedBox(height: 10),
            Text('4. Share your creation with others!'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it!'))],
      ),
    );
  }
}
