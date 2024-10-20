import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './User_Option.dart';
import 'firebase_options.dart'; // Import firebase_options.dart for Firebase config

// Import the state class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use platform-specific Firebase options
  );
  runApp(const PublicPulseApp());
}




class PublicPulseApp extends StatelessWidget {
  const PublicPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PublicPulse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),

    );
  }
}

// Splash Screen with App Name, Motto, and "Get Started" Button
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'PublicPulse',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                  color: Colors.indigo
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Your Concerns, Our Commitment.',
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
                  color: Colors.blue
              ),
            ),
            const SizedBox(height: 40.0),
            Container(
              width: 350.0,
              height: 350.0,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: AssetImage('assets/logo.jpg'),  // Make sure this path is valid
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const UserTypeSelection()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//logo
class BackgroundImageWrapper extends StatelessWidget {
  final Widget child; // The main content of each page will be passed here

  const BackgroundImageWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Image with Opacity

          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjust opacity as needed
              child: Image.asset(
                'assets/logo.jpg', // Path to your logo image
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          // Main content passed as a child
          child,
        ],
      ),
    );
  }
}








