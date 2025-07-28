import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';
import '../widgets/permission_wrapper.dart';

class PhotoEditingScreen extends StatefulWidget {
  const PhotoEditingScreen({super.key});

  @override
  State<PhotoEditingScreen> createState() => _PhotoEditingScreenState();
}

class _PhotoEditingScreenState extends State<PhotoEditingScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _imageKey = GlobalKey();

  String? _uploadedImagePath;
  UserProfile? _userProfile;
  OverlayStyle _selectedStyle = OverlayStyle.circular;
  Color _backgroundColor = Colors.white; // Changed to white background
  Offset _profilePhotoPosition = const Offset(50, 50);
  PhotoShape _photoShape = PhotoShape.circle;
  double _profilePhotoSize = 80.0; // Add size control
  bool _isLoading = false;
  bool _showBusinessDetails = true; // Control for showing business details

  // Image container size controls
  double _imageContainerHeight = 0.6; // 60% of screen height by default
  double _imageContainerWidth = 1.0; // 100% of available width by default

  // Text styling controls
  Color _textColor = Colors.black; // Default text color
  double _nameFontSize = 20.0; // Default name font size
  double _businessFontSize = 16.0; // Default business font size
  double _phoneFontSize = 14.0; // Default phone font size

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Proactively request permission when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionService.requestPhotoPermission(context);
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await StorageService.getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionService.requestPhotoPermission(context);
    if (!hasPermission) {
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (image != null) {
      setState(() {
        _uploadedImagePath = image.path;
        _profilePhotoPosition = const Offset(50, 50);
        _profilePhotoSize = 80.0; // Reset size to default
        _showBusinessDetails = true; // Reset business details toggle
        _imageContainerHeight = 0.6; // Reset container height
        _imageContainerWidth = 1.0; // Reset container width
        _textColor = Colors.black; // Reset text color
        _nameFontSize = 20.0; // Reset name font size
        _businessFontSize = 16.0; // Reset business font size
        _phoneFontSize = 14.0; // Reset phone font size
      });
    }
  }

  void _changeBackgroundColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Background Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _backgroundColor,
            onColorChanged: (color) {
              setState(() {
                _backgroundColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  void _changeTextColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Text Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _textColor,
            onColorChanged: (color) {
              setState(() {
                _textColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _shareImage() async {
    if (_uploadedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload an image first')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Force a rebuild to ensure current state is captured
      setState(() {});

      // Wait for the rebuild to complete
      await Future.delayed(const Duration(milliseconds: 200));

      final bytes = await _captureImage();
      if (bytes != null) {
        // Create a unique filename with timestamp to avoid caching issues
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempDir = await Directory.systemTemp.createTemp('overlay_me');
        final file = File('${tempDir.path}/overlay_image_$timestamp.png');
        await file.writeAsBytes(bytes);

        // Ensure the file exists and is readable
        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Check out my overlay created with Overlay Me!',
            subject: 'Overlay Me - Custom Photo Overlay',
          );
        } else {
          throw Exception('Failed to create temporary file for sharing');
        }
      } else {
        throw Exception('Failed to capture image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing image: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Uint8List?> _captureImage() async {
    try {
      // Ensure the widget is built and rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('RenderRepaintBoundary not found');
        return null;
      }

      // Wait for the boundary to be ready
      if (!boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('Failed to convert image to bytes');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Editor'),
        actions: [
          if (_uploadedImagePath != null)
            IconButton(icon: const Icon(Icons.share), onPressed: _isLoading ? null : _shareImage),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Style Selection
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Overlay Style: '),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SegmentedButton<OverlayStyle>(
                      segments: const [
                        ButtonSegment(value: OverlayStyle.circular, label: Text('Circular'), icon: Icon(Icons.circle)),
                        ButtonSegment(value: OverlayStyle.details, label: Text('Details'), icon: Icon(Icons.info)),
                      ],
                      selected: {_selectedStyle},
                      onSelectionChanged: (Set<OverlayStyle> selection) {
                        setState(() {
                          _selectedStyle = selection.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Image Display Area - 60% of screen height
            if (_uploadedImagePath == null)
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PermissionWrapper(
                  permissionMessage: 'Photo Permission Required',
                  onPermissionGranted: () {
                    // Permission granted, user can now upload
                  },
                  child: _buildUploadPrompt(),
                ),
              ),

            // RepaintBoundary for capturing the entire composition
            if (_uploadedImagePath != null)
              RepaintBoundary(
                key: _imageKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Photo Container
                      Container(
                        height: MediaQuery.of(context).size.height * _imageContainerHeight,
                        width: MediaQuery.of(context).size.width * _imageContainerWidth,
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(8),
                                  topRight: const Radius.circular(8),
                                  bottomLeft:
                                      (_selectedStyle == OverlayStyle.circular && _showBusinessDetails) ||
                                          (_selectedStyle == OverlayStyle.details)
                                      ? Radius.zero
                                      : const Radius.circular(8),
                                  bottomRight:
                                      (_selectedStyle == OverlayStyle.circular && _showBusinessDetails) ||
                                          (_selectedStyle == OverlayStyle.details)
                                      ? Radius.zero
                                      : const Radius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    Image.file(
                                      File(_uploadedImagePath!),
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                    // Overlay
                                    if (_selectedStyle == OverlayStyle.circular)
                                      _buildCircularOverlay()
                                    else
                                      _buildDetailsOverlay(),
                                  ],
                                ),
                              ),
                            ),

                            // Business Details Container (for circular style)
                            if (_selectedStyle == OverlayStyle.circular && _showBusinessDetails)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _backgroundColor.withOpacity(0.95),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildBusinessDetailsContent(),
                              ),

                            // Business Details Container (for details style)
                            if (_selectedStyle == OverlayStyle.details)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _backgroundColor.withOpacity(0.95),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _buildDetailsBusinessContent(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Controls
            if (_uploadedImagePath != null)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_selectedStyle == OverlayStyle.circular) ...[
                      Row(
                        children: [
                          const Text('Photo Shape: '),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SegmentedButton<PhotoShape>(
                              segments: const [
                                ButtonSegment(value: PhotoShape.circle, label: Text('Circle')),
                                ButtonSegment(value: PhotoShape.square, label: Text('Square')),
                                ButtonSegment(value: PhotoShape.rectangle, label: Text('Rectangle')),
                              ],
                              selected: {_photoShape},
                              onSelectionChanged: (Set<PhotoShape> selection) {
                                setState(() {
                                  _photoShape = selection.first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Photo Size: '),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Slider(
                              value: _profilePhotoSize,
                              min: 40.0,
                              max: 150.0,
                              divisions: 11,
                              label: '${_profilePhotoSize.round()}px',
                              onChanged: (value) {
                                setState(() {
                                  _profilePhotoSize = value;
                                });
                              },
                            ),
                          ),
                          Text('${_profilePhotoSize.round()}'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text('Drag the profile photo to reposition it'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _profilePhotoPosition = const Offset(50, 50);
                                  _profilePhotoSize = 80.0;
                                  _showBusinessDetails = true;
                                  _imageContainerHeight = 0.6;
                                  _imageContainerWidth = 1.0;
                                  _textColor = Colors.black;
                                  _nameFontSize = 20.0;
                                  _businessFontSize = 16.0;
                                  _phoneFontSize = 14.0;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Position & Size'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          const Text('Background Color: '),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _changeBackgroundColor,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _backgroundColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedStyle == OverlayStyle.circular) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Details Background: '),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _changeBackgroundColor,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _backgroundColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Show Business Details: '),
                          const SizedBox(width: 10),
                          Switch(
                            value: _showBusinessDetails,
                            onChanged: (value) {
                              setState(() {
                                _showBusinessDetails = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Image Container Size Controls
                    const Text('Image Container Size', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Height: '),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _imageContainerHeight,
                            min: 0.3,
                            max: 0.8,
                            divisions: 10,
                            label: '${(_imageContainerHeight * 100).round()}%',
                            onChanged: (value) {
                              setState(() {
                                _imageContainerHeight = value;
                              });
                            },
                          ),
                        ),
                        Text('${(_imageContainerHeight * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Width: '),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _imageContainerWidth,
                            min: 0.5,
                            max: 1.0,
                            divisions: 10,
                            label: '${(_imageContainerWidth * 100).round()}%',
                            onChanged: (value) {
                              setState(() {
                                _imageContainerWidth = value;
                              });
                            },
                          ),
                        ),
                        Text('${(_imageContainerWidth * 100).round()}%'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _imageContainerHeight = 0.6;
                                _imageContainerWidth = 1.0;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Container Size'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Text Styling Controls
                    const Text('Text Styling', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Text Color: '),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _changeTextColor,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _textColor,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Name Font Size: '),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _nameFontSize,
                            min: 14.0,
                            max: 32.0,
                            divisions: 18,
                            label: '${_nameFontSize.round()}px',
                            onChanged: (value) {
                              setState(() {
                                _nameFontSize = value;
                              });
                            },
                          ),
                        ),
                        Text('${_nameFontSize.round()}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Business Font Size: '),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _businessFontSize,
                            min: 12.0,
                            max: 24.0,
                            divisions: 12,
                            label: '${_businessFontSize.round()}px',
                            onChanged: (value) {
                              setState(() {
                                _businessFontSize = value;
                              });
                            },
                          ),
                        ),
                        Text('${_businessFontSize.round()}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Phone Font Size: '),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Slider(
                            value: _phoneFontSize,
                            min: 10.0,
                            max: 20.0,
                            divisions: 10,
                            label: '${_phoneFontSize.round()}px',
                            onChanged: (value) {
                              setState(() {
                                _phoneFontSize = value;
                              });
                            },
                          ),
                        ),
                        Text('${_phoneFontSize.round()}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _textColor = Colors.black;
                                _nameFontSize = 20.0;
                                _businessFontSize = 16.0;
                                _phoneFontSize = 14.0;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Text Styling'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Upload New Image'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _shareImage,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.share),
                            label: Text(_isLoading ? 'Sharing...' : 'Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Upload a Photo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Choose a photo from your gallery to add overlays',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload),
            label: const Text('Select Photo'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularOverlay() {
    if (_userProfile?.profilePhotoPath == null) {
      return const SizedBox.shrink(); // Don't show anything if no profile photo
    }

    return Positioned(
      left: _profilePhotoPosition.dx,
      top: _profilePhotoPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _profilePhotoPosition += details.delta;
          });
        },
        child: Container(
          width: _profilePhotoSize,
          height: _profilePhotoSize,
          decoration: BoxDecoration(
            shape: _photoShape == PhotoShape.circle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: _photoShape == PhotoShape.rectangle ? BorderRadius.circular(8) : null,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: _photoShape == PhotoShape.circle
                ? BorderRadius.circular(_profilePhotoSize / 2)
                : BorderRadius.circular(_photoShape == PhotoShape.rectangle ? 8 : 0),
            child: Image.file(File(_userProfile!.profilePhotoPath!), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsOverlay() {
    // Return empty widget since business details are now in a separate container below the photo
    return const SizedBox.shrink();
  }

  Widget _buildBusinessDetailsContent() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _userProfile!.name ?? 'Name',
          style: TextStyle(color: _textColor, fontSize: _nameFontSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _userProfile!.businessDetails ?? 'Business',
          style: TextStyle(color: _textColor, fontSize: _businessFontSize),
        ),
        if (_userProfile!.phoneNumber != null) ...[
          const SizedBox(height: 5),
          Text(
            _userProfile!.phoneNumber!,
            style: TextStyle(color: _textColor, fontSize: _phoneFontSize),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsBusinessContent() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (_userProfile!.profilePhotoPath != null)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(child: Image.file(File(_userProfile!.profilePhotoPath!), fit: BoxFit.cover)),
          ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userProfile!.name ?? 'Name',
                style: TextStyle(color: _textColor, fontSize: _nameFontSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _userProfile!.businessDetails ?? 'Business',
                style: TextStyle(color: _textColor, fontSize: _businessFontSize),
              ),
              if (_userProfile!.phoneNumber != null) ...[
                const SizedBox(height: 5),
                Text(
                  _userProfile!.phoneNumber!,
                  style: TextStyle(color: _textColor, fontSize: _phoneFontSize),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum OverlayStyle { circular, details }

enum PhotoShape { circle, square, rectangle }
