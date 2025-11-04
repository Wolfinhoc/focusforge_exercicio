import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import '../services/prefs_service.dart';

class UserAvatar extends StatefulWidget {
  final String? name;

  const UserAvatar({
    Key? key,
    this.name,
  }) : super(key: key);

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final imageData = await PrefsService.loadAvatar();
    if (imageData != null && mounted) {
      setState(() => _imageData = imageData);
    }
  }

  String _getInitials() {
    final name = widget.name;
    if (name == null || name.trim().isEmpty) {
      return '';
    }
    final names = name.trim().split(' ').where((n) => n.isNotEmpty);
    if (names.length > 1) {
      return names.first[0].toUpperCase() + names.last[0].toUpperCase();
    }
    return names.first[0].toUpperCase();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageBytes = await ImageService.processAvatar(File(pickedFile.path));
      setState(() {
        _imageData = imageBytes;
      });
      await PrefsService.saveAvatar(imageBytes);
    }
  }

  Future<void> _removeAvatar() async {
    await PrefsService.removeAvatar();
    if (mounted) {
      setState(() {
        _imageData = null;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            if (_imageData != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover Foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  _removeAvatar();
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Foto de perfil. Toque para alterar.',
      button: true,
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Tooltip(
          message: 'Alterar foto de perfil',
          child: CircleAvatar(
            radius: 24, // Garante um diâmetro de 48dp
            backgroundImage: _imageData != null ? MemoryImage(_imageData!) : null,
            child: _imageData == null ? Text(_getInitials()) : null,
          ),
        ),
      ),
    );
  }
}