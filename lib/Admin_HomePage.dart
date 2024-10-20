import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './AdminCommunityChat_GOAT.dart';
import './Admin_Feedback.dart';
import './Admin_Dashboard.dart';
import './Admin_Progress.dart';
import './Admin_AccountSettings.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.adminEmail, required this.adminDepartment});

  final String adminEmail;
  final String adminDepartment;

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalComplaints = 0;
  int resolvedComplaints = 0;
  String adminID = '';   // Placeholder for admin ID
  String adminEmail = ''; // Placeholder for admin email
  String adminDepartment = '';

  @override
  void initState() {
    super.initState();
    fetchComplaintData();
    fetchAdminDetails();
  }

  // Fetch complaint data from Firestore
  Future<void> fetchComplaintData() async {
    final QuerySnapshot complaintsSnapshot = await FirebaseFirestore.instance.collection('complaints').get();

    int totalCount = complaintsSnapshot.docs.length;
    int resolvedCount = complaintsSnapshot.docs.where((doc) => doc['status'] == 'Resolved').length;

    setState(() {
      totalComplaints = totalCount;
      resolvedComplaints = resolvedCount;
    });
  }

  // Fetch admin details from Firestore (admin_id, email, and department)
  Future<void> fetchAdminDetails() async {

    QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: widget.adminEmail) // Use the passed email
        .limit(1)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      var adminData = adminSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
          adminID = adminData['admin_id'] ?? 'Unknown Admin ID'; // Added fallback value
          adminEmail = adminData['email'] ?? 'Unknown Email';
          adminDepartment = adminData['dept_name'] ?? 'Unknown Department';  // Fetch the department
        });

        print('Admin ID: $adminID, Admin Department: $adminDepartment');  // Debugging print

      } else {
        print('Admin not found in Firestore.');
      }
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjust this value to make the image lighter or darker
              child: Image.asset(
                'assets/logo.jpg', // Path to your image
                fit: BoxFit.scaleDown, // Ensure the image covers the whole screen
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // App Name Header
              Container(
                color: Colors.blue,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'PublicPulse',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              // Admin Details (Now Dynamic)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin ID: $adminID',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Admin Email: ${widget.adminEmail}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Admin Department: $adminDepartment',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Overall Complaints Status
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Complaints Status',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Complaints Statistics
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Complaints: $totalComplaints',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Resolved Complaints: $resolvedComplaints',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Bottom Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButton('Feedback', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminFeedbackPage(adminDepartment: adminDepartment),
                        ),
                      );

                    }),
                    _buildBottomButton('Dashboard', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboard()));
                    }),
                    _buildBottomButton(
                      'Community',
                          () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatApp()));
                      },
                    ),
                    _buildBottomButton('Progress', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProgressPage(adminDepartment: adminDepartment),
                        ),
                      );

                    }),
                    _buildBottomButton('Account', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminSettingsPage()));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build bottom buttons
  Widget _buildBottomButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
