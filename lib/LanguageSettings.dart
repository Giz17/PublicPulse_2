import 'package:flutter/material.dart';

class LanguageSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('English'),
            trailing: Icon(Icons.check), // Show checkmark if selected
            onTap: () {
              // Code to change language to English
            },
          ),
          ListTile(
            title: Text('Spanish'),
            onTap: () {
              // Code to change language to Spanish
            },
          ),
          ListTile(
            title: Text('French'),
            onTap: () {
              // Code to change language to French
            },
          ),
        ],
      ),
    );
  }
}
