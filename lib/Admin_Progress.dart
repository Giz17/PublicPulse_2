import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProgressPage extends StatefulWidget {
  const AdminProgressPage({super.key});

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
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> complaints = snapshot.data!.docs;

          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              DocumentSnapshot complaint = complaints[index];

              // Safely access the fields
              String complaintId = complaint['complaint_id'];
              String status = complaint['status'] ?? 'Pending'; // Default to 'Pending'
              String department = complaint['dept_name'];
              String comments = complaint['details'];

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
