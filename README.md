# Overlay Me - Flutter Photo Overlay App

A Flutter application that allows users to create personalized photo overlays by combining their profile information with uploaded images.

## Features

### 🎯 Onboarding & Profile Management

- **Multi-step onboarding process** with profile photo upload, name, business details, and phone number
- **Local storage** of user profile data using SharedPreferences
- **Profile editing** with dedicated edit screen
- **Profile reset** functionality

### 📸 Photo Editing & Overlays

- **Image upload** from device gallery
- **Two overlay styles**:
  1. **Circular Profile Photo Overlay**:
     - Draggable profile photo overlay
     - Multiple shape options (circle, square, rectangle)
     - Position customization
  2. **Profile Details Overlay**:
     - Profile photo and details in a container
     - Customizable background colors
     - Professional layout design

### 🎨 Customization Options

- **Profile photo positioning** (drag and drop)
- **Photo shape selection** (circle, square, rectangle)
- **Background color picker** for details overlay
- **Real-time preview** of changes

### 📤 Sharing Functionality

- **Image capture** of the final overlay
- **Share to external apps** (social media, messaging, etc.)
- **High-quality output** with proper resolution

## Technical Implementation

### Architecture

- **MVVM pattern** with separation of concerns
- **Service layer** for data persistence
- **Model classes** for data management
- **Screen-based navigation** with named routes

### Dependencies

- `image_picker`: Image selection from gallery
- `shared_preferences`: Local data storage
- `permission_handler`: Photo access permissions with comprehensive handling
- `share_plus`: Image sharing functionality
- `flutter_colorpicker`: Color selection for backgrounds
- `path_provider`: File system operations

### Key Components

#### Models

- `UserProfile`: Data model for user information
- `OverlayStyle`: Enum for overlay types
- `PhotoShape`: Enum for photo shape options

#### Services

- `StorageService`: Handles local data persistence
- `PermissionService`: Manages photo access permissions

#### Screens

- `SplashScreen`: App initialization and onboarding check
- `OnboardingScreen`: Multi-step profile setup
- `HomeScreen`: Main navigation hub
- `ProfileScreen`: Profile display and management
- `ProfileEditScreen`: Profile editing interface
- `PhotoEditingScreen`: Main photo overlay creation

#### Widgets

- `PermissionWrapper`: Reusable widget for permission handling

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator or Android Emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd overlay_me
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android

- Minimum SDK: 21
- Target SDK: 33
- Permissions:
  - `READ_EXTERNAL_STORAGE` - Access to photo library
  - `READ_MEDIA_IMAGES` - Access to images (Android 13+)
  - `WRITE_EXTERNAL_STORAGE` - Save shared images
  - `CAMERA` - Camera access (for future features)
  - `INTERNET` - Sharing functionality

#### iOS

- Minimum iOS version: 12.0
- Permissions:
  - Photo Library access with usage description
  - Camera access with usage description

## Usage Guide

### First Time Setup

1. Launch the app
2. Complete the onboarding process:
   - Upload a profile photo
   - Enter your name
   - Add business details
   - Provide phone number
3. Start creating overlays!

### Creating Photo Overlays

1. Navigate to "Create Photo Overlay"
2. Upload an image from your gallery
3. Choose overlay style:
   - **Circular**: Drag profile photo to desired position
   - **Details**: Profile info with customizable background
4. Customize settings (shape, color, position)
5. Share your creation!

### Managing Profile

- Access profile via the person icon in the app bar
- Edit profile information anytime
- Reset profile to start over

## File Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── user_profile.dart     # User profile data model
├── services/
│   ├── storage_service.dart  # Local storage service
│   └── permission_service.dart # Permission management
├── widgets/
│   └── permission_wrapper.dart # Permission UI wrapper
└── screens/
    ├── onboarding_screen.dart    # Profile setup
    ├── home_screen.dart          # Main navigation
    ├── profile_screen.dart       # Profile display
    ├── profile_edit_screen.dart  # Profile editing
    └── photo_editing_screen.dart # Photo overlay creation
```

## Features in Detail

### Onboarding Flow

- **Step 1**: Profile photo upload with image picker
- **Step 2**: Name input with proper validation
- **Step 3**: Business details collection
- **Step 4**: Phone number input
- **Completion**: Automatic navigation to home screen

### Photo Overlay Styles

#### Circular Overlay

- Profile photo appears as a draggable overlay
- Three shape options: circle, square, rectangle
- White border with shadow for visibility
- Real-time position updates

#### Details Overlay

- Profile information displayed in a bottom container
- Semi-transparent background with rounded corners
- Profile photo, name, business, and phone number
- Customizable background color

### Permission Handling

- **Comprehensive permission management** for photo library access
- **Proactive permission requests** - app actively requests permissions when needed
- **User-friendly permission requests** with clear explanations
- **Graceful handling** of denied and permanently denied permissions
- **Automatic permission checks** before photo operations
- **Settings integration** for permanently denied permissions
- **Reusable permission wrapper** for consistent UX
- **Platform-specific permissions** properly declared in manifests

#### Permission Flow

1. **App Launch**: Permission check during splash screen
2. **Onboarding**: Explicit permission request for profile photo
3. **Photo Editing**: Permission verification before image upload
4. **Profile Editing**: Permission check for photo updates
5. **Fallback UI**: Clear permission request screens when access is denied

### Sharing Implementation

- Uses `RepaintBoundary` for high-quality image capture
- Temporary file creation for sharing
- Integration with system share sheet
- Support for all sharing destinations

## Future Enhancements

- [ ] Multiple overlay templates
- [ ] Text customization options
- [ ] Filter effects for photos
- [ ] Cloud storage integration
- [ ] Social media direct posting
- [ ] Batch processing capabilities
- [ ] Advanced editing tools

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository or contact the development team.

---

**Overlay Me** - Create stunning photo overlays with your personal touch! 📱✨
