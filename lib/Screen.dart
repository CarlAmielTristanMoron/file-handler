import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'image_model.dart';

class Screen extends StatefulWidget {
  const Screen({Key? key}) : super(key: key);

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  late final ImageModel _model;

  @override
  void initState() {
    super.initState();
    _model = ImageModel();
  }

  Future<void> _checkPermissionsAndPick() async {
    final hasFilePermission = await _model.requestPermission();
    if (hasFilePermission) {
      try {
        await _model.pickFile();
      } on Exception catch (e) {
        debugPrint('Error when picking a file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occured when picking a file'),
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<ImageModel>(
        builder: (context, model, child) {
          Widget widget;

          switch(model.imageSection) {
            case ImageSection.noStoragePermission:
              widget = Permission(isPermanent: false, onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.noStoragePermissionPermanent:
              widget = Permission(isPermanent: true, onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.browseFiles:
              widget = _PickFile(onPressed: _checkPermissionsAndPick);
              break;
            case ImageSection.imageLoaded:
              widget = _ImageLoaded(file: _model.file!);
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Image Viewer'),
            ),
          );
        },
      ),
    );
  }
}

class Permission extends StatelessWidget {
  const Permission({
    Key? key,
    required this.isPermanent,
    required this.onPressed
  }) : super(key: key);

  final bool isPermanent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24
              ),
              child: const Text('Read files Permission'),
            ),
            Container(
              padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24
              ),
              child: const Text('We need access to your storage to load them into the app'),
            ),
            if (isPermanent)
              Container(
                padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 24
                ),
                child: const Text('You need to goto settings to access permission'),
              ),
            Container(
              padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24
              ),
              child: ElevatedButton(
                child: Text(isPermanent ? 'Open Settings' : 'Allow Access'),
                onPressed: () => isPermanent ? openAppSettings() : onPressed(),
              )
            ),
          ],
        ),
    );
  }
}

class _PickFile extends StatelessWidget {

  const _PickFile({
    Key? key,
    required this.onPressed
  }) : super(key:key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Pick a File')
    ),
  );
}

class _ImageLoaded extends StatelessWidget {

  const _ImageLoaded({
    Key? key,
    required this.file
  }) : super(key:key);

  final File file;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 196,
        height: 196,
        child: ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
  }

}
