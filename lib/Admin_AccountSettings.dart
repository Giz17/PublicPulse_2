import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _username = "AdminUser";
  String _email = "admin@example.com";
  String _securityQuestion = "What was your first pet's name?";
  final String _adminId = ""; // Admin's Firestore document ID

  // Reference to Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  // Fetch the admin data from Firestore
  Future<void> _fetchAdminData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String email = currentUser.email!;
        DocumentSnapshot adminDoc = await _firestore
            .collection('admins') // Assuming 'admins' collection exists
            .doc(email) // Admin's document is stored with their email as ID
            .get();

        if (adminDoc.exists) {
          setState(() {
            _username = adminDoc['username'];
            _email = adminDoc['email'];
            _darkMode = adminDoc['darkMode'];
            _notificationsEnabled = adminDoc['notificationsEnabled'];
            _securityQuestion = adminDoc['securityQuestion'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching admin data: $e'),
      ));
    }
  }

  // Update data in Firestore when changes are made
  Future<void> _updateAdminData(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('admins').doc(_email).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating data: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Username Field
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Username"),
              subtitle: Text(_username),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _changeUsername();
                },
              ),
            ),
            const Divider(),

            // Email Field
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(_email),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _changeEmail();
                },
              ),
            ),
            const Divider(),

            // Dark Mode Switch
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                });
                _updateAdminData({'darkMode': value});
              },
              secondary: const Icon(Icons.brightness_6),
            ),
            const Divider(),

            // Notifications Switch
            SwitchListTile(
              title: const Text("Enable Notifications"),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _updateAdminData({'notificationsEnabled': value});
              },
              secondary: const Icon(Icons.notifications),
            ),
            const Divider(),

            // Security Question
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Security Question"),
              subtitle: Text(_securityQuestion),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _changeSecurityQuestion();
                },
              ),
            ),
            const Divider(),

            // Save Button (Optional, since we're auto-saving on changes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Settings Saved Automatically'),
              ),
            ),

            // Logout Button
            TextButton(
              onPressed: _logout,
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to change the username
  void _changeUsername() {
    showDialog(
      context: context,
      builder: (context) {
        String newUsername = _username;
        return AlertDialog(
          title: const Text('Change Username'),
          content: TextField(
            onChanged: (value) {
              newUsername = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter new username',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _username = newUsername;
                });
                _updateAdminData({'username': newUsername});
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to change the email
  void _changeEmail() {
    showDialog(
      context: context,
      builder: (context) {
        String newEmail = _email;
        return AlertDialog(
          title: const Text('Change Email'),
          content: TextField(
            onChanged: (value) {
              newEmail = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter new email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _email = newEmail;
                });
                _updateAdminData({'email': newEmail});
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to change the security question
  void _changeSecurityQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        String newQuestion = _securityQuestion;
        return AlertDialog(
          title: const Text('Change Security Question'),
          content: TextField(
            onChanged: (value) {
              newQuestion = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter new security question',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _securityQuestion = newQuestion;
                });
                _updateAdminData({'securityQuestion': newQuestion});
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Logout function
  void _logout() {
    _auth.signOut();
    Navigator.pop(context); // Go back to login or previous page
  }
}
