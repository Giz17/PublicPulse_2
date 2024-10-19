import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintProgressPage extends StatelessWidget {
  const ComplaintProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Progress'),
      ),
      body: const ComplaintList(), // Calls the widget displaying complaints
    );
  }
}

// Widget to list complaints from Firestore
class ComplaintList extends StatelessWidget {
  const ComplaintList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var complaintDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: complaintDocs.length,
          itemBuilder: (context, index) {
            var complaint = complaintDocs[index];

            // Accessing complaint details and handling null status
            String complaintId = complaint['complaint_id'];
            String status = complaint['status'] ?? 'Pending'; // Default value if 'status' is missing;
            String deptName = complaint['dept_name'];

            return ComplaintCard(
              complaintId: complaintId,
              status: status,
              department: deptName,
            );
          },
        );
      },
    );
  }
}

// Widget for each complaint card
class ComplaintCard extends StatelessWidget {
  final String complaintId;
  final String status;
  final String department;

  const ComplaintCard({
    super.key,
    required this.complaintId,
    required this.status,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor() {
      switch (status) {
        case 'Resolved':
          return Colors.green.shade200;
        case 'In Progress':
          return Colors.orange.shade200;
        case 'Pending':
          return Colors.blue.shade200;
        default:
          return Colors.grey.shade200;
      }
    }

    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              color: getStatusColor(),
              child: Text('Status: $status'),
            ),
            const SizedBox(height: 8.0),
            Text('Complaint ID: $complaintId'),
            Text('Department: $department'),
          ],
        ),
      ),
    );
  }
}
