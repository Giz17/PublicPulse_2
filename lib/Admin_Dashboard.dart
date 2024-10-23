import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  final String adminDepartment; // Admin's department

  const AdminDashboard({super.key, required this.adminDepartment});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String searchQuery = '';
  String sortBy = 'Date';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search complaints by title...',
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
                DropdownButton<String>(
                  value: sortBy,
                  items: <String>['Date', 'Priority'].map((String value) {
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
          // Complaint Listing
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('dept_name', isEqualTo: widget.adminDepartment) // Filter by admin's department
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter and sort complaints based on user input
                List<QueryDocumentSnapshot> complaints = snapshot.data!.docs;

                // Apply Search Filter (Search by complaint title)
                if (searchQuery.isNotEmpty) {
                  complaints = complaints
                      .where((doc) => doc['complaint_title']
                      .toLowerCase()
                      .contains(searchQuery))
                      .toList();
                }

                // Apply Sorting (Sort by Date or Priority)
                complaints.sort((a, b) {
                  if (sortBy == 'Date') {
                    return a['date'].compareTo(b['date']);
                  } else {
                    return a['priority']?.compareTo(b['priority']) ?? 0;
                  }
                });

                // Display complaints in a ListView
                return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    var complaint = complaints[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Complaint Title: ${complaint['complaint_title']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${complaint['date']}'),
                            Text('User: ${complaint['email']}'),
                            Text('Comments: ${complaint['details']}'),
                            Text('Status: ${complaint['status'] ?? "Pending"}'),
                            Text('Priority: ${complaint['priority'] ?? "None"}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Popup Menu
                            PopupMenuButton<String>(
                              onSelected: (newStatus) {
                                updateComplaintStatus(complaint.id, newStatus);
                              },
                              itemBuilder: (BuildContext context) {
                                return ['Pending', 'In Progress', 'Resolved'].map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text('Set Status: $choice'),
                                  );
                                }).toList();
                              },
                              child: const Icon(Icons.more_vert), // Icon for status update
                            ),
                            // Priority Popup Menu
                            PopupMenuButton<String>(
                              onSelected: (newPriority) {
                                updateComplaintPriority(complaint.id, newPriority);
                              },
                              itemBuilder: (BuildContext context) {
                                return ['High', 'Medium', 'Low'].map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text('Set Priority: $choice'),
                                  );
                                }).toList();
                              },
                              child: const Icon(Icons.flag), // Icon for priority update
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Update the priority of the complaint in Firestore
  void updateComplaintPriority(String complaintId, String newPriority) {
    FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'priority': newPriority}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint priority updated to $newPriority')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update priority: $error')),
      );
    });
  }

  // Update the status of the complaint in Firestore
  void updateComplaintStatus(String complaintId, String newStatus) {
    FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'status': newStatus}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint status updated to $newStatus')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    });
  }
}
