import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './Admin_LoginPage.dart';

class AdminSettingsPage extends StatefulWidget {
  final String adminEmail;

  const AdminSettingsPage({super.key, required this.adminEmail});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _notificationsEnabled = true;
  String _email = "Loading...";
  String _contact = "Loading...";
  String _deptName = "Loading...";
  String _adminId = "Loading..."; // Admin's ID

  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  // Fetch admin details from Firestore (admin_id, email, and department)
  Future<void> _fetchAdminData() async {
    QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: widget.adminEmail)
        .limit(1)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      var adminData = adminSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _adminId = adminData['admin_id'] ?? 'Unknown Admin ID'; // Fetch admin ID
        _email = adminData['email'] ?? widget.adminEmail;
        _contact = adminData['contact'] ?? 'Not Set';
        _deptName = adminData['dept_name'] ?? 'Not Set';
        _notificationsEnabled = adminData['notificationsEnabled'] ?? false;

      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin data does not exist in Firestore.')),
      );
    }
  }

  // Update admin data in Firestore
  Future<void> _updateAdminData(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('admin').doc(widget.adminEmail).update(data);
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
              title: const Text("Admin ID"),
              subtitle: Text(_adminId),
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

            // Department Name Field
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text("Department"),
              subtitle: Text(_deptName),
            ),
            const Divider(),

            // Contact Field
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text("Contact"),
              subtitle: Text(_contact),
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
        String newUsername = _adminId;
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
                  _adminId = newUsername;
                });
                _updateAdminData({'admin_id': newUsername});
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


  // Logout function
  void _logout() {
    // Navigate to the AdminLoginPage and replace the current page.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginPage()),
    );
  }

}
