import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';

class AdminCommunityChatPage extends StatefulWidget {
  final String adminName; // Admin's name
  final String adminDepartment; // Admin's department

  const AdminCommunityChatPage({
    super.key,
    required this.adminName,
    required this.adminDepartment,
  });

  @override
  _AdminCommunityChatPageState createState() => _AdminCommunityChatPageState();
}

class _AdminCommunityChatPageState extends State<AdminCommunityChatPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('admin_community_chat').add({
        'content': _controller.text,
        'timestamp': Timestamp.now(),
        'sender': widget.adminName, // Admin's name
        'dept_name': widget.adminDepartment, // Admin's department
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Community Chat'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('admin_community_chat')
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
                        alignment: message['sender'] == widget.adminName
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        nip: message['sender'] == widget.adminName
                            ? BubbleNip.rightTop
                            : BubbleNip.leftTop,
                        color: message['sender'] == widget.adminName
                            ? Colors.greenAccent
                            : Colors.blueAccent,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
