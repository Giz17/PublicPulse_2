import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'FirestoreService.dart'; // Reference to your FirestoreService class

class AddFeedbackPage extends StatefulWidget {
  final String complaintId; // Pass complaintId for which feedback is being submitted
  final String email; // The email of the user submitting feedback

  const AddFeedbackPage({super.key, required this.complaintId, required this.email});

  @override
  _AddFeedbackPageState createState() => _AddFeedbackPageState();
}

class _AddFeedbackPageState extends State<AddFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  int timeliness = 1;
  int effectiveness = 1;
  int communication = 1;
  final TextEditingController _commentsController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique feedback ID
      String feedbackId = FirebaseFirestore.instance.collection('feedback').doc().id;

      try {
        await _firestoreService.addFeedback(
          complaintId: widget.complaintId,
          feedbackId: feedbackId,
          email: widget.email,
          timeliness: timeliness,
          effectiveness: effectiveness,
          communication: communication,
          comments: _commentsController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Timeliness:'),
              Slider(
                value: timeliness.toDouble(),
                min: 1,
                max: 5,
                divisions: 5,
                label: timeliness.toString(),
                onChanged: (value) {
                  setState(() {
                    timeliness = value.toInt();
                  });
                },
              ),
              const Text('Effectiveness:'),
              Slider(
                value: effectiveness.toDouble(),
                min: 1,
                max: 5,
                divisions: 5,
                label: effectiveness.toString(),
                onChanged: (value) {
                  setState(() {
                    effectiveness = value.toInt();
                  });
                },
              ),
              const Text('Communication:'),
              Slider(
                value: communication.toDouble(),
                min: 1,
                max: 5,
                divisions: 5,
                label: communication.toString(),
                onChanged: (value) {
                  setState(() {
                    communication = value.toInt();
                  });
                },
              ),
              TextFormField(
                controller: _commentsController,
                decoration: const InputDecoration(labelText: 'Additional Comments'),
                maxLines: 4,
              ),
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
