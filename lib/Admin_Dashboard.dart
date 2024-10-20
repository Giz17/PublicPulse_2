import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String searchQuery = '';
  String selectedDepartment = 'All';
  String sortBy = 'Date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search complaints...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Filter and Sort Options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter by Department Dropdown
                DropdownButton<String>(
                  value: selectedDepartment,
                  items: <String>['All', 'HR', 'IT', 'Finance', 'Admin']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedDepartment = newValue!;
                    });
                  },
                ),
                // Sort by Dropdown
                DropdownButton<String>(
                  value: sortBy,
                  items: <String>['Date', 'email']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('Sort by $value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      sortBy = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Department-wise Complaint Listing
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter and sort complaints based on user input
                List<QueryDocumentSnapshot> complaints = snapshot.data!.docs;

                // Apply Department Filter
                if (selectedDepartment != 'All') {
                  complaints = complaints
                      .where((doc) => doc['dept_name'] == selectedDepartment)
                      .toList();
                }

                // Apply Search Filter
                if (searchQuery.isNotEmpty) {
                  complaints = complaints
                      .where((doc) =>
                  doc['email'].toLowerCase().contains(searchQuery) ||
                      doc['details'].toLowerCase().contains(searchQuery))
                      .toList();
                }

                // Apply Sorting
                complaints.sort((a, b) {
                  if (sortBy == 'Date') {
                    return a['date'].compareTo(b['date']);
                  } else {
                    return a['email'].compareTo(b['email']);
                  }
                });

                // Group complaints by department
                Map<String, List<QueryDocumentSnapshot>> deptComplaints = {};
                for (var complaint in complaints) {
                  String dept = complaint['dept_name'];
                  if (!deptComplaints.containsKey(dept)) {
                    deptComplaints[dept] = [];
                  }
                  deptComplaints[dept]!.add(complaint);
                }

                // Display complaints grouped by department
                return ListView(
                  children: deptComplaints.keys.map((department) {
                    return ExpansionTile(
                      title: Text(department),
                      children: deptComplaints[department]!.map((complaint) {
                        return ListTile(
                          title: Text('Complaint ID: ${complaint['complaint_id']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${complaint['date']}'),
                              Text('User: ${complaint['email']}'),
                              Text('Comments: ${complaint['details']}'),
                              Text('Status: ${complaint['status']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteComplaint(complaint.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.reply, color: Colors.blue),
                                onPressed: () {
                                  respondToComplaint(context, complaint.id);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void deleteComplaint(String complaintId) {
    FirebaseFirestore.instance.collection('complaints').doc(complaintId).delete();
  }

  void respondToComplaint(BuildContext context, String complaintId) {
    // Navigate to response page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RespondPage(complaintId: complaintId),
      ),
    );
  }
}

class RespondPage extends StatelessWidget {
  final String complaintId;

  const RespondPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Respond to Complaint $complaintId'),
      ),
      body: const Center(
        child: Text('Response form goes here.'),
      ),
    );
  }
}