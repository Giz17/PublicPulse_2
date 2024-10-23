import 'package:flutter/material.dart';

class PrivacySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Profile Visibility'),
            subtitle: Text('Control who can see your profile'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Profile Visibility page
            },
          ),
          ListTile(
            title: Text('Block Users'),
            subtitle: Text('Manage blocked users'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Block Users page
            },
          ),
          ListTile(
            title: Text('Location Sharing'),
            subtitle: Text('Control whether your location is shared'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Location Sharing page
            },
          ),
        ],
      ),
    );
  }
}
