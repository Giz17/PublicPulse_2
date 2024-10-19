import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './AdminCommunityChat_GOAT.dart';
import './Admin_Feedback.dart';
import './Admin_Dashboard.dart';
import './Admin_Progress.dart';
import './Admin_AccountSettings.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int totalComplaints = 0;
  int resolvedComplaints = 0;
  String adminID = '';   // Placeholder for admin ID
  String adminEmail = ''; // Placeholder for admin email

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

  // Fetch admin details from Firestore (admin_id and email)
  Future<void> fetchAdminDetails() async {
    // Assuming there is a collection called 'admin' and fetching a specific admin document
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance.collection('admin').doc('admin_id').get();

    setState(() {
      adminID = adminSnapshot['admin_id'];    // Ensure field names match your Firestore structure
      adminEmail = adminSnapshot['email'];
    });
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
                      'Admin Email: $adminEmail',
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminFeedbackPage()));
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProgressPage()));
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
