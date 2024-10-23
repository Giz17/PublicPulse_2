import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class CallSupport extends StatelessWidget {
  final String phoneNumber = '8669088242'; // Define the phone number

  // Function to initiate the phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Support'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need immediate help? Call us at:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                phoneNumber, // Display the contact number
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _makePhoneCall(phoneNumber); // Call the phone number when pressed
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
