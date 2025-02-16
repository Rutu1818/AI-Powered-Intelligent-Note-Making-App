import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../services/stt_service.dart';
import '../services/gcs_service.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isUploading = false;
  File? _selectedFile;
  String? _fileName;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _uploadLecture() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and enter title')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload file to GCS
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading file...')),
      );
      
      final fileUrl = await GCSService.uploadFile(_selectedFile!);

      // Store in Firestore
      DocumentReference docRef = await FirebaseFirestore.instance.collection('lectures').add({
        'title': _titleController.text,
        'file_url': fileUrl,
        'file_name': _fileName,
        'storage_type': 'Google Cloud Storage',
        'timestamp': FieldValue.serverTimestamp(),
        'transcript': '',
        'transcriptionComplete': false,
        'transcriptionError': null,
      });

      // Start transcription
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting transcription...')),
      );

      await STTService.transcribeAudio(docRef.id, fileUrl);
      
      _titleController.clear();
      setState(() {
        _selectedFile = null;
        _fileName = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lecture uploaded and transcription started!')),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Lecture Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => 
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: Icon(Icons.attach_file),
                label: Text(_fileName ?? 'Select Audio File'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadLecture,
                child: _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Upload Lecture'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
