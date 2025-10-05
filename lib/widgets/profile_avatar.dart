import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatefulWidget {
  final String? imagePath;
  final void Function(String path)? onImageChanged;

  const ProfileAvatar({super.key, this.imagePath, this.onImageChanged});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imagePath = picked.path;
      });
      if (widget.onImageChanged != null) {
        widget.onImageChanged!(picked.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: _imagePath != null
              ? FileImage(File(_imagePath!))
              : const AssetImage('assets/images/demo_service.png') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: PopupMenuButton<ImageSource>(
            icon: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ImageSource.camera,
                child: Text('Camera'),
              ),
              const PopupMenuItem(
                value: ImageSource.gallery,
                child: Text('Gallery'),
              ),
            ],
            onSelected: _pickImage,
          ),
        ),
      ],
    );
  }
}

