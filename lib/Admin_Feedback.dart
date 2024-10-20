import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackPage extends StatelessWidget {
  final String adminDepartment; // Add a parameter for the admin's department

  const AdminFeedbackPage({super.key, required this.adminDepartment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Feedback Page'),
      ),
      body: StreamBuilder(
        // Filter complaints by the admin's department
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('dept_name', isEqualTo: adminDepartment) // Filter by department
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var complaint = snapshot.data!.docs[index];
              return Card(
                child: ExpansionTile(
                  title: Text('Complaint ID: ${complaint['complaint_id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${complaint['date']}'),
                      Text('User: ${complaint['email']}'),
                      Text('Department: ${complaint['dept_name']}'),
                      Text('Status: ${complaint['status']}'),
                    ],
                  ),
                  children: [
                    // Fetch and display feedback
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('complaints')
                          .doc(complaint.id)
                          .collection('feedback')
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> feedbackSnapshot) {
                        if (!feedbackSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (feedbackSnapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No feedback available for this complaint.'),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true, // To allow the ListView to fit in ExpansionTile
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: feedbackSnapshot.data!.docs.length,
                          itemBuilder: (context, feedbackIndex) {
                            var feedback = feedbackSnapshot.data!.docs[feedbackIndex];
                            return ListTile(
                              title: Text('Feedback from: ${feedback['email']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Timeliness: ${feedback['timeliness']}'),
                                  Text('Effectiveness: ${feedback['effectiveness']}'),
                                  Text('Communication: ${feedback['communication']}'),
                                  Text('Comments: ${feedback['comments']}'),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Delete and Respond options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void deleteComplaint(String complaintId) {
    FirebaseFirestore.instance.collection('complaints').doc(complaintId).delete();
  }

  void respondToComplaint(BuildContext context, String complaintId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RespondPage(complaint_id: complaintId),
      ),
    );
  }
}



class RespondPage extends StatefulWidget {
  final String complaint_id;

  const RespondPage({super.key, required this.complaint_id});

  @override
  _RespondPageState createState() => _RespondPageState();
}

class _RespondPageState extends State<RespondPage> {
  final TextEditingController _responseController = TextEditingController();
  String status = 'Pending'; // Default status

  // Function to handle submitting the response
  Future<void> _submitResponse() async {
    String response = _responseController.text.trim();

    if (response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a response before submitting.')),
      );
      return;
    }

    try {
      // Update the complaint with admin's response and status
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaint_id)
          .update({
        'admin_response': response,
        'status': status,
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Respond to Complaint ${widget.complaint_id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Response:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _responseController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your response',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Update Complaint Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: status,
              onChanged: (String? newValue) {
                setState(() {
                  status = newValue!;
                });
              },
              items: <String>['Pending', 'In Progress', 'Resolved', 'Rejected']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitResponse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Submit Response'),
            ),
          ],
        ),
      ),
    );
  }
}
