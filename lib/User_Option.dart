import 'package:flutter/material.dart';
import 'package:publicpulse_2/main.dart';
import './Admin_LoginPage.dart';
import './Citizen_Option.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWrapper( // Use BackgroundImageWrapper here
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PublicPulse - User Type'),
          backgroundColor: Colors.blue.withOpacity(0.8), // Slight opacity for better readability
        ),
        backgroundColor: Colors.transparent, // Ensure the background is transparent
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'PublicPulse',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const Text(
                'Your Concerns, Our Commitment',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const AdminLoginPage()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Admin',  style: TextStyle(color: Colors.white), ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const CitizenOptionsPage()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Citizen',  style: TextStyle(color: Colors.white), ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}