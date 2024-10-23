

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart'; // Add this
import 'package:firebase_storage/firebase_storage.dart'; // Add this

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
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  bool notifyMe = false;
  String? fileUrl;
  PlatformFile? pickedFile; // File picker variable

  final FirestoreService _firestoreService = FirestoreService();

  String? selectedDepartment; // To store the selected department

  // Function to pick and upload a file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });

      // Upload the file to Firebase Storage
      String fileName = pickedFile!.name;
      Reference storageRef = FirebaseStorage.instance.ref().child('complaints/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(pickedFile!.path!));

      // Get the file URL after upload is complete
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      fileUrl = await snapshot.ref.getDownloadURL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File uploaded successfully: $fileName')),
      );
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      // Generate a unique complaint ID
      String complaintId = FirebaseFirestore.instance.collection('complaints').doc().id; // Unique ID
      String date = DateTime.now().toIso8601String();
      String email = FirebaseAuth.instance.currentUser?.email ?? ''; // Replace with actual user email

      try {
        await _firestoreService.addComplaint(
          complaintId: complaintId,
          address: _addressController.text,
          complaintTitle: _complaintTitleController.text,
          date: date,
          deptName: selectedDepartment ?? '', // Store selected department
          details: _detailsController.text,
          fileUrl: fileUrl ?? '',
          notifyMe: notifyMe,
          pincode: _pincodeController.text,
          status: _statusController.text,
          email: email,
          priority: _priorityController.text,
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
        backgroundColor: Colors.blue,
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
              // Dropdown for selecting the department
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department Name'),
                items: ['PWD', 'Municipality', 'Electricity Dept'].map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a department' : null,
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
              // File upload button
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(pickedFile != null ? 'Change File' : 'Upload File'),
              ),
              if (pickedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected file: ${pickedFile!.name}'),
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

