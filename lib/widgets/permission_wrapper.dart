import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../services/permission_service.dart';

class PermissionWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;
  final String? permissionMessage;

  const PermissionWrapper({
    super.key,
    required this.child,
    this.onPermissionGranted,
    this.onPermissionDenied,
    this.permissionMessage,
  });

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _hasPermission = false;
  bool _isChecking = true;
  Timer? _permissionCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _startPermissionCheckTimer();
  }

  @override
  void dispose() {
    _permissionCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await PermissionService.hasPhotoPermission();
    setState(() {
      _hasPermission = hasPermission;
      _isChecking = false;
    });

    // If permission is not granted, proactively request it
    if (!hasPermission) {
      // Add a small delay to ensure the widget is fully built
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        _requestPermission();
      }
    }
  }

  Future<void> _requestPermission() async {
    final hasPermission = await PermissionService.requestPhotoPermission(context);

    // Refresh the permission status to ensure we have the latest state
    final refreshedStatus = await PermissionService.refreshPermissionStatus();

    setState(() {
      _hasPermission = refreshedStatus;
    });

    if (refreshedStatus) {
      widget.onPermissionGranted?.call();
    } else {
      widget.onPermissionDenied?.call();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    final refreshedStatus = await PermissionService.refreshPermissionStatus();
    setState(() {
      _hasPermission = refreshedStatus;
      _isChecking = false;
    });
  }

  void _startPermissionCheckTimer() {
    // Check permission status every 5 seconds when permission is not granted
    _permissionCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_hasPermission && mounted) {
        final refreshedStatus = await PermissionService.refreshPermissionStatus();
        if (refreshedStatus != _hasPermission) {
          setState(() {
            _hasPermission = refreshedStatus;
          });
          if (refreshedStatus) {
            widget.onPermissionGranted?.call();
            timer.cancel(); // Stop checking once permission is granted
          }
        }
      } else if (_hasPermission) {
        timer.cancel(); // Stop checking if permission is already granted
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasPermission) {
      return widget.child;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            widget.permissionMessage ?? 'Photo Permission Required',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'This feature requires access to your photo library to work properly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _requestPermission,
            icon: const Icon(Icons.photo_library),
            label: const Text('Grant Photo Permission'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: _refreshPermissionStatus, child: const Text('Refresh Status')),
              TextButton(onPressed: () => openAppSettings(), child: const Text('Open Settings')),
            ],
          ),
        ],
      ),
    );
  }
}
