import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './AccountSettings.dart';
import './CommunityChat_GOAT.dart';
import './ComplaintPage.dart';
import './ComplaintProgressPage.dart';
import './FeedbackPage.dart';

class CitizenHomePage extends StatefulWidget {
  const CitizenHomePage({super.key});

  @override
  _CitizenHomePageState createState() => _CitizenHomePageState();
}

class _CitizenHomePageState extends State<CitizenHomePage> {
  String _searchQuery = '';
  String _filterBy = '';
  final List<String> _filters = ['Date', 'Dept'];
  final String _selectedDept = 'All'; // Default selected department


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/logo.jpg', // Path to your image
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // App Name Header
              Container(
                color: Colors.blue,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'PublicPulse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16.0),
              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search Complaints',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Filter Options and Department Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter buttons
                    Row(
                      children: _filters.map((filter) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filterBy = filter;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _filterBy == filter ? Colors.blueAccent : Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          child: Text('Filter by $filter', style: TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                    // Department dropdown
                   
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Complaints List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No complaints found.'));
                    }

                    // Fetch complaints from Firestore
                    List<DocumentSnapshot> complaints = snapshot.data!.docs;

                    // Apply search query filter (if any)
                    if (_searchQuery.isNotEmpty) {
                      complaints = complaints.where((complaint) {
                        String title = complaint['complaint_title'].toLowerCase();
                        return title.contains(_searchQuery.toLowerCase());
                      }).toList();
                    }

                    // Apply filter by Date
                    if (_filterBy == 'Date') {
                      // Sort complaints by Date (assumes 'date' is a timestamp field in Firestore)
                      complaints.sort((a, b) {
                        String dateA = a['date'];
                        String dateB = b['date'];
                        return dateA.compareTo(dateB);
                      });
                    }

                    // Apply department filter
                    if (_selectedDept != 'All') {
                      complaints = complaints.where((complaint) {
                        return complaint['dept_name'] == _selectedDept;
                      }).toList();
                    }

                    // Sort complaints by Department name if the Dept filter is selected
                    if (_filterBy == 'Dept') {
                      complaints.sort((a, b) {
                        String deptA = a['dept_name'];
                        String deptB = b['dept_name'];
                        return deptA.compareTo(deptB);
                      });
                    }

                    // Display the filtered and sorted list of complaints
                    return ListView.builder(
                      itemCount: complaints.length,
                      itemBuilder: (context, index) {
                        var complaint = complaints[index];
                        String title = complaint['complaint_title'];
                        String date = complaint['date'];
                        String dept = complaint['dept_name'];

                        return ListTile(
                          title: Text(title),
                          subtitle: Text('Dept: $dept | Date: $date'),
                          onTap: () {
                            // Handle complaint tap action here
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Add Complaint Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddComplaintPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  child: const Text('Add Complaint', style: TextStyle(color: Colors.white)),
                ),
              ),

              // Icon Buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildIconButton(
                      Icons.feedback,
                      'Feedback',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectComplaintPage(), // Navigate to complaint selection
                          ),
                        );
                        // Example complaint ID
                      },
                    ),
                    _buildIconButton(
                      Icons.group,
                      'Community',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CommunityChatPage()),
                        );
                      },
                    ),
                    _buildIconButton(
                      Icons.bar_chart,
                      'Progress',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => const ComplaintProgressPage()),
                        );
                      },
                    ),
                    _buildIconButton(
                      Icons.person,
                      'Account',
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (
                              context) => const AccountSettingsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build filter buttons
  Widget _buildFilterButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // Action for each filter button
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  // Helper method to build icon buttons
  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Navigate to FeedbackPage
  void navigateToAddFeedbackPage(BuildContext context) {
    // Get the currently logged-in user
    User? loggedInUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (loggedInUser != null) {
      String userEmail = loggedInUser.email ?? '';

      // Ensure complaintId is available
      String? complaintId = _getComplaintId(); // Fetch the actual complaintId

      if (complaintId != null && complaintId.isNotEmpty) {
        // Navigate to FeedbackPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddFeedbackPage(
              email: userEmail, // Pass the user's email
              complaintId: complaintId, // Pass the fetched complaintId
            ),
          ),
        );
      } else {
        // Handle case where complaintId is not available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No complaint selected.')),
        );
      }
    } else {
      // Handle the case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User is not authenticated. Please log in.')),
      );
    }
  }

  // Logic to fetch the complaintId
  String? _getComplaintId() {
    // Retrieve complaintId from where it was stored after complaint submission
    // For example, you might store it in shared preferences or pass it via the state management
    return AddComplaintPage.complaintId; // Replace with actual logic to fetch complaintId
  }
}





class SelectComplaintPage extends StatelessWidget {
  const SelectComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Complaint'),
        backgroundColor: Colors.blue,
      ),
      body: ComplaintList(),
    );
  }
}

class ComplaintList extends StatelessWidget {
  // Get the current user's email
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

  ComplaintList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('email', isEqualTo: userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No complaints found.'));
        }

        // If complaints are found, display them in a ListView
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot complaint = snapshot.data!.docs[index];
            String complaintTitle = complaint['complaint_title'];
            String complaintId = complaint['complaint_id'];

            return ListTile(
              title: Text(complaintTitle),
              subtitle: Text('Complaint ID: $complaintId'),
              onTap: () {
                // When a complaint is selected, navigate to the AddFeedbackPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFeedbackPage(
                      email: userEmail, // Pass the user's email
                      complaintId: complaintId, // Pass the selected complaintId
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
