import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class STTService {
  static const String _apiScope = speech.SpeechApi.cloudPlatformScope;
  static const String _jsonKeyPath = 'assets/service_acc.json';

  static Future<void> transcribeAudio(String docId, String audioUrl) async {
    try {
      // Load service account credentials
      final credentials = await rootBundle.loadString(_jsonKeyPath);
      final serviceAccount = auth.ServiceAccountCredentials.fromJson(credentials);
      final client = await auth.clientViaServiceAccount(serviceAccount, [_apiScope]);
      final speechApi = speech.SpeechApi(client);

      // Download audio file from URL
      final audioResponse = await http.get(Uri.parse(audioUrl));
      final audioContent = base64Encode(audioResponse.bodyBytes);

      // Create recognition request
      var config = speech.RecognitionConfig(
        encoding: "MP3",
        sampleRateHertz: 16000,
        languageCode: "en-US",
      );

      var audio = speech.RecognitionAudio(content: audioContent);
      var request = speech.RecognizeRequest(config: config, audio: audio);

      // Perform transcription
      var response = await speechApi.speech.recognize(request);

      // Extract transcript
      String transcript = response.results
          ?.map((result) => result.alternatives?.first.transcript ?? "")
          .join(" ") ?? "No transcription found.";

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('lectures')
          .doc(docId)
          .update({
        'transcript': transcript,
        'transcriptionComplete': true,
      });

    } catch (e) {
      print('Transcription error: $e');
      await FirebaseFirestore.instance
          .collection('lectures')
          .doc(docId)
          .update({
        'transcriptionError': e.toString(),
      });
    }
  }
}
