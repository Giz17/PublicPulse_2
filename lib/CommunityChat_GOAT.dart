import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';

class CommunityChatPage extends StatelessWidget {
  const CommunityChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Show Snackbar when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can chat.'),
          duration: Duration(seconds: 3), // Display for 3 seconds
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Community Chat'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('admin_community_chat') // Fetch messages from admin chat collection
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    var timestamp = message['timestamp'] as Timestamp;
                    var dateTime = timestamp.toDate();
                    var formattedTime = "${dateTime.hour}:${dateTime.minute}";

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Bubble(
                        alignment: Alignment.topLeft,
                        nip: BubbleNip.leftTop,
                        color: Colors.lightBlueAccent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${message['sender']} (${message['dept_name']})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message['content'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
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
          // The citizens can only view messages, so no TextField or send button will be included here.
        ],
      ),
    );
  }
}
