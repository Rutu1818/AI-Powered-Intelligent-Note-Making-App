import 'dart:io';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

class GCSService {
  static const String _bucketName = 'ai_bucket18'; // Your bucket name
  static const String _jsonKeyPath = 'assets/service_acc.json';

  static Future<String> uploadFile(File file) async {
    try {
      // Load credentials
      final credentials = await rootBundle.loadString(_jsonKeyPath);
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(credentials);
      
      // Get authenticated client
      final client = await auth.clientViaServiceAccount(
        accountCredentials, 
        [storage.StorageApi.devstorageFullControlScope]
      );
      
      // Create Storage API client
      final storageApi = storage.StorageApi(client);

      // Read file content
      List<int> fileBytes = await file.readAsBytes();
      
      // Create unique filename
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      
      // Upload file
      await storageApi.objects.insert(
        storage.Object()..name = fileName,
        _bucketName,
        uploadMedia: storage.Media(Stream.fromIterable([fileBytes]), fileBytes.length),
      );

      // Generate public URL
      final url = 'https://storage.googleapis.com/$_bucketName/$fileName';
      return url;

    } catch (e) {
      print('GCS Upload error: $e');
      throw Exception('Failed to upload file to Google Cloud Storage');
    }
  }
}

