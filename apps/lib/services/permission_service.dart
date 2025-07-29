import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static const String _photoPermissionMessage =
      'This app needs access to your photos to create overlays. Please grant permission to continue.';

  static const String _photoPermissionDeniedMessage =
      'Photo permission is required to use this feature. Please enable it in your device settings.';

  /// Request photo library permission
  static Future<bool> requestPhotoPermission(BuildContext context) async {
    // Try different photo permissions based on Android version
    List<Permission> permissionsToTry = [Permission.photos, Permission.storage];

    PermissionStatus finalStatus = PermissionStatus.denied;

    for (Permission permission in permissionsToTry) {
      // Check current status first
      PermissionStatus currentStatus = await permission.status;

      // If already granted, return true immediately
      if (currentStatus.isGranted) {
        return true;
      }

      // Request permission
      PermissionStatus status = await permission.request();
      finalStatus = status;

      if (status.isGranted) {
        return true;
      }
    }

    // If permission was denied, show explanation and try again
    if (finalStatus.isDenied) {
      final shouldTryAgain = await _showPermissionExplanationDialog(context);
      if (shouldTryAgain) {
        final status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }
        finalStatus = status;
      }
    }

    // Handle permanently denied or restricted
    if (finalStatus.isPermanentlyDenied || finalStatus.isRestricted) {
      _showPermissionDialog(context, true);
      return false;
    }

    // Handle denied
    if (finalStatus.isDenied) {
      _showPermissionDialog(context, false);
      return false;
    }

    return false;
  }

  /// Check if photo permission is granted
  static Future<bool> hasPhotoPermission() async {
    // Try different photo permissions
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;

    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted;
  }

  /// Refresh permission status and return current state
  static Future<bool> refreshPermissionStatus() async {
    // Try different photo permissions
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;

    final storageStatus = await Permission.storage.status;
    return storageStatus.isGranted;
  }

  /// Show permission explanation dialog
  static Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Photo Permission Needed'),
            content: const Text(
              'This app needs access to your photos to create overlays. '
              'Without this permission, you won\'t be able to upload photos or create overlays. '
              'Would you like to try again?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show permission dialog
  static void _showPermissionDialog(BuildContext context, bool isPermanentlyDenied) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(isPermanentlyDenied ? _photoPermissionDeniedMessage : _photoPermissionMessage),
        actions: [
          if (isPermanentlyDenied)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show permission explanation snackbar
  static void showPermissionSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(label: 'Settings', onPressed: () => openAppSettings()),
      ),
    );
  }
}
