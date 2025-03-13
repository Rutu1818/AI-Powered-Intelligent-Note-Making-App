import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TranscriptDetailScreen extends StatefulWidget {  // Changed to StatefulWidget
  final DocumentSnapshot lecture;

  const TranscriptDetailScreen(this.lecture, {super.key});

  @override
  State<TranscriptDetailScreen> createState() => _TranscriptDetailScreenState();
}

class _TranscriptDetailScreenState extends State<TranscriptDetailScreen> {
  bool _isEditing = false;
  late TextEditingController _transcriptController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController(text: widget.lecture['transcript']);
  }

  Future<void> _saveTranscript() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('lectures')
          .doc(widget.lecture.id)
          .update({'transcript': _transcriptController.text});
      
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transcript saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving transcript: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lecture['title']),
        actions: [
          if (_isEditing)
            IconButton(
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveTranscript,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lecture Transcript",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_isEditing)
                TextField(
                  controller: _transcriptController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(fontSize: 16),
                )
              else
                Text(
                  widget.lecture['transcript'],
                  style: const TextStyle(fontSize: 16)
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }
}
