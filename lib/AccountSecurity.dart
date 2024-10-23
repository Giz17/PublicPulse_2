import 'package:flutter/material.dart';
import './Citizen_LogIn.dart';
class AccountSecurity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Security'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Change Password page
            },
          ),
          ListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add an extra layer of security'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Two-Factor Authentication page
            },
          ),
          const Divider(), // Add a divider for separation

          // Logout option for citizens
          ListTile(
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            trailing: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              _logout(context); // Call the logout function
            },
          ),
        ],
      ),
    );
  }

  // Logout function
  void _logout(BuildContext context) {
    // Navigate to the CitizenLoginPage and replace the current screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CitizenLoginPage()),
    );
  }
}
