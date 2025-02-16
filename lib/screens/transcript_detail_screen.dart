import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TranscriptDetailScreen extends StatelessWidget {
  final DocumentSnapshot lecture;

  const TranscriptDetailScreen(this.lecture, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lecture['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lecture Transcript",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(lecture['transcript'], style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
