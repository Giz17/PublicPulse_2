import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProgressPage extends StatefulWidget {
  final String adminDepartment; // Add a parameter for the admin's department

  const AdminProgressPage({super.key, required this.adminDepartment});

  @override
  _AdminProgressPageState createState() => _AdminProgressPageState();
}

class _AdminProgressPageState extends State<AdminProgressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Progress Page'),
      ),
      body: StreamBuilder(
        // Filter complaints by the admin's department
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('dept_name', isEqualTo: widget.adminDepartment) // Filter by department
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Debugging: Log snapshot connection state
          print('Snapshot connection state: ${snapshot.connectionState}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Loading complaints for department: ${widget.adminDepartment}'); // Debugging log
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error loading complaints: ${snapshot.error}'); // Debugging log
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No complaints found for department: ${widget.adminDepartment}'); // Debugging log
            return const Center(
              child: Text('No complaints found for this department.'),
            );
          }

          List<DocumentSnapshot> complaints = snapshot.data!.docs;

          // Debugging: Log number of complaints retrieved
          print('Complaints retrieved: ${complaints.length}');

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              DocumentSnapshot complaint = complaints[index];

              // Debugging: Log complaint data
              print('Complaint Data: ${complaint.data()}');

              // Safely access the fields
              String complaintId = complaint['complaint_id'] ?? 'Unknown ID';
              String status = complaint['status'] ?? 'Pending'; // Default to 'Pending'
              String department = complaint['dept_name'] ?? 'Unknown Department';
              String comments = complaint['details'] ?? 'No details provided';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Complaint ID: $complaintId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Department: $department'),
                      Text('Comments: $comments'),
                      Text('Status: $status'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (newStatus) {
                      print('Selected new status: $newStatus for Complaint ID: $complaintId'); // Debugging log
                      updateComplaintStatus(complaintId, newStatus);
                    },
                    itemBuilder: (BuildContext context) {
                      return ['Pending', 'In Progress', 'Resolved'].map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    child: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Update the status of the complaint in Firestore
  void updateComplaintStatus(String complaintId, String newStatus) {
    // Debugging: Log update request
    print('Updating complaint $complaintId to status: $newStatus');

    FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({'status': newStatus}).then((_) {
      // Debugging: Log success
      print('Complaint $complaintId updated successfully to $newStatus');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint status updated to $newStatus')),
      );
    }).catchError((error) {
      // Debugging: Log error
      print('Error updating complaint $complaintId: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    });
  }
}
