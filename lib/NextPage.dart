import 'package:flutter/material.dart';

// Next Page where complaintId will be used
class NextPage extends StatelessWidget {
  final String complaintId;

  // Constructor to receive complaintId
  const NextPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint ID: $complaintId'),
      ),
      body: Center(
        child: Text(
          'Complaint Submitted Successfully!\nYour Complaint ID is: $complaintId',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
