import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:typed_data';

class STTService {
  static const String _apiScope = speech.SpeechApi.cloudPlatformScope;
  static const String _jsonKeyPath = 'assets/service_acc.json';
  static const int _chunkSize = 10 * 1024 * 1024; // 10MB chunks

  static Future<void> transcribeAudio(String docId, String audioUrl) async {
    try {
      // Load credentials
      final credentials = await rootBundle.loadString(_jsonKeyPath);
      final serviceAccount = auth.ServiceAccountCredentials.fromJson(credentials);
      final client = await auth.clientViaServiceAccount(serviceAccount, [_apiScope]);
      final speechApi = speech.SpeechApi(client);

      // Download audio file
      final audioResponse = await http.get(Uri.parse(audioUrl));
      final audioBytes = audioResponse.bodyBytes;
      
      // Split into chunks
      List<String> transcripts = [];
      for (var i = 0; i < audioBytes.length; i += _chunkSize) {
        final end = (i + _chunkSize < audioBytes.length) ? i + _chunkSize : audioBytes.length;
        final chunk = audioBytes.sublist(i, end);
        
        // Update Firestore with progress
        await FirebaseFirestore.instance
            .collection('lectures')
            .doc(docId)
            .update({
          'transcriptionProgress': '${((i / audioBytes.length) * 100).toInt()}%',
        });

        // Process chunk
        final chunkTranscript = await _transcribeChunk(speechApi, chunk);
        transcripts.add(chunkTranscript);
      }

      // Combine all transcripts and update Firestore
      final fullTranscript = transcripts.join(' ');
      await FirebaseFirestore.instance
          .collection('lectures')
          .doc(docId)
          .update({
        'transcript': fullTranscript,
        'transcriptionComplete': true,
        'transcriptionProgress': '100%',
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

  static Future<String> _transcribeChunk(speech.SpeechApi speechApi, List<int> audioData) async {
    final audioContent = base64Encode(audioData);

    var config = speech.RecognitionConfig(
      encoding: "MP3",
      sampleRateHertz: 16000,
      languageCode: "en-US",
      enableAutomaticPunctuation: true,
    );

    var audio = speech.RecognitionAudio(content: audioContent);
    var request = speech.RecognizeRequest(config: config, audio: audio);

    try {
      var response = await speechApi.speech.recognize(request);
      return response.results
          ?.map((result) => result.alternatives?.first.transcript ?? "")
          .join(" ") ?? "";
    } catch (e) {
      print('Chunk transcription error: $e');
      return "";
    }
  }
}
