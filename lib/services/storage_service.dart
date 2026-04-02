import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a product photo and return the download URL.
  Future<String> uploadProductPhoto({
    required File file,
    required String productId,
  }) async {
    final ext = _extension(file.path);
    final ref = _storage.ref(
        '${AppConstants.productPhotosPath}/$productId/photo$ext');
    return await _upload(ref, file);
  }

  /// Upload a rating photo and return the download URL.
  Future<String> uploadRatingPhoto({
    required File file,
    required String ratingId,
  }) async {
    final ext = _extension(file.path);
    final ref = _storage
        .ref('${AppConstants.ratingPhotosPath}/$ratingId/photo$ext');
    return await _upload(ref, file);
  }

  /// Upload a user avatar and return the download URL.
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final ext = _extension(file.path);
    final ref =
        _storage.ref('${AppConstants.avatarsPath}/$userId/avatar$ext');
    return await _upload(ref, file);
  }

  /// Delete a file at [url] from Firebase Storage.
  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('StorageService.deleteFileByUrl error: $e');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<String> _upload(Reference ref, File file) async {
    final metadata = SettableMetadata(
      contentType: _contentType(file.path),
      customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
    );

    final task = ref.putFile(file, metadata);

    // Monitor progress
    task.snapshotEvents.listen((event) {
      if (event.totalBytes > 0) {
        final progress = event.bytesTransferred / event.totalBytes;
        debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      }
    });

    await task;
    return await ref.getDownloadURL();
  }

  String _extension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) return '.${parts.last.toLowerCase()}';
    return '.jpg';
  }

  String _contentType(String path) {
    final ext = _extension(path).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
