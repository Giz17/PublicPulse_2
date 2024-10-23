import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './EmailSupport.dart';
import './CallSupport.dart';
import './Admin_LoginPage.dart'; // Import the Admin Login Page

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Get current user ID from Firebase Auth
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // Save updated profile information to Firestore
  Future<void> _saveProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  }

  // Logout method
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginPage()), // Navigate to Admin Login Page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Call logout method on button press
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('No profile data found.'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            // Populate the text controllers with existing user data
            _addressController.text = userData['address'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _nameController.text = userData['name'] ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Edit Profile Section
                const Text(
                  'Edit Profile Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16.0),

                // Address
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Phone Number
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 32.0),

                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile'),
                ),

                const SizedBox(height: 32.0),

                // About Public Pulse Section
                const Text(
                  'About Public Pulse',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Public Pulse is dedicated to providing a platform for citizens\' grievances to government departments. '
                      'Our mission is to empower citizens who want to make the government departments aware of the difficulties faced by them.',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24.0),

                // Contact Information
                const Text(
                  'Contact Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8.0),
                const Text('For support, reach out to us via email or phone.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16.0),

                // Email Support and Call Support buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Navigate to Email Support Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmailSupport()),
                          );
                        },
                        icon: const Icon(Icons.email, color: Colors.white),
                        label: const Text('Email Support'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // Navigate to Call Support Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CallSupport()),
                          );
                        },
                        icon: const Icon(Icons.phone, color: Colors.white),
                        label: const Text('Call Support'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32.0),
              ],
            );
          },
        ),
      ),
    );
  }
}
