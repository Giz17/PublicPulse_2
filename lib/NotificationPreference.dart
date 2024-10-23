import 'package:flutter/material.dart';

class NotificationPreferences extends StatefulWidget {
  @override
  _NotificationPreferencesState createState() => _NotificationPreferencesState();
}

class _NotificationPreferencesState extends State<NotificationPreferences> {
  bool emailNotifications = true;
  bool pushNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Preferences'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Email Notifications'),
            value: emailNotifications,
            onChanged: (value) {
              setState(() {
                emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Push Notifications'),
            value: pushNotifications,
            onChanged: (value) {
              setState(() {
                pushNotifications = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
