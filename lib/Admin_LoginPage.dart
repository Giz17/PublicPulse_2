import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './Admin_HomePage.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = ''; // To display error messages

  // Function to validate login
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();


      // Fetch admin data from Firestore based on email
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: email)
          .limit(1) // Limit to one result to ensure efficiency
          .get();

      // Check if the result is not empty (i.e., admin exists)
      if (result.docs.isNotEmpty) {
        // Admin exists, now validate password
        final adminData = result.docs[0].data() as Map<String, dynamic>;

        if (adminData['password'] == password) {
          // Password is correct, ensure one admin per department
          String adminDepartment = adminData['dept_name'];

          // Navigate to AdminHomePage, passing email and department
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminHomePage(
                adminEmail: adminData['email'], // Pass admin email
                adminDepartment: adminDepartment, // Pass department to the home page
              ),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'Invalid password. Please try again.';
          });
        }
      } else {
        // No matching admin found
        setState(() {
          errorMessage = 'Admin with this email does not exist.';
        });
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Image with Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjust this value to make the image lighter or darker
              child: Image.asset(
                'assets/logo.jpg', // Path to your image
                fit: BoxFit.scaleDown, // Ensure the image covers the whole screen
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back! Enter your credentials to login.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Admin Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Admin Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                // Error message display
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
