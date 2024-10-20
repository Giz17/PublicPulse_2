import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'FirestoreService.dart'; // Reference to your FirestoreService class

class AddComplaintPage extends StatefulWidget {
  static String? complaintId;

  const AddComplaintPage({super.key});

  @override
  _AddComplaintPageState createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _complaintTitleController = TextEditingController();
  final TextEditingController _deptNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  bool notifyMe = false;
  String? fileUrl;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique complaint ID
      String complaintId = FirebaseFirestore.instance.collection('complaints').doc().id; // Unique ID
      String date = DateTime.now().toIso8601String();
      String email= FirebaseAuth.instance.currentUser?.email ?? ''; // Replace with actual user email

      try {
        await _firestoreService.addComplaint(
          complaintId: complaintId,
          address: _addressController.text,
          complaintTitle: _complaintTitleController.text,
          date: date,
          deptName: _deptNameController.text,
          details: _detailsController.text,
          fileUrl: fileUrl ?? '',
          notifyMe: notifyMe,
          pincode: _pincodeController.text,
          status: _statusController.text,
          email: email,

        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
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
        title: const Text('Submit Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter address' : null,
              ),
              TextFormField(
                controller: _complaintTitleController,
                decoration: const InputDecoration(labelText: 'Complaint Title'),
                validator: (value) => value!.isEmpty ? 'Please enter complaint title' : null,
              ),
              TextFormField(
                controller: _deptNameController,
                decoration: const InputDecoration(labelText: 'Department Name'),
                validator: (value) => value!.isEmpty ? 'Please enter department name' : null,
              ),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Complaint Details'),
                validator: (value) => value!.isEmpty ? 'Please enter details' : null,
                maxLines: 4,
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                validator: (value) => value!.isEmpty ? 'Please enter pincode' : null,
              ),
              CheckboxListTile(
                title: const Text('Notify Me'),
                value: notifyMe,
                onChanged: (bool? value) {
                  setState(() {
                    notifyMe = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
