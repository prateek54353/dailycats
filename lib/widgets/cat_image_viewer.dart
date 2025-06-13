import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart' as saver;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class CatImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? caption;
  const CatImageViewer({super.key, required this.imageUrl, this.caption});

  Future<void> _saveToGallery(BuildContext context) async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final res = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = res.bodyBytes;
    await saver.ImageGallerySaverPlus.saveImage(bytes, name: 'daily_cat');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cat saved to gallery 🐱')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _saveToGallery(context),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
              errorWidget: (c, e, s) => const Center(child: Icon(Icons.error)),
            ),
          ),
          if (caption != null)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            )
        ],
      ),
    );
  }
}
