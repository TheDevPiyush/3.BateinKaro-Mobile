import 'package:chatting_app/components/alert_box.dart';
import 'package:chatting_app/components/appbar_on_users.dart';
import 'package:chatting_app/signup_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() async {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        "send by": FirebaseAuth.instance.currentUser?.displayName,
      });

      _messageController.clear();
    }
  }

  @override
  void initState() {
    online();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      online();
    } else if (state == AppLifecycleState.paused) {
      offline();
    }
  }

  online() async {
    await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"status": "Online"});
  }

  offline() async {
    await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"status": "Offline"});
  }

  @override
  Widget build(BuildContext context) {
    logout() {
      signout(context);
      offline();
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 65, 0, 177),
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Let's Gossip !"),
                AppBarOnlineUserList(),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'option1') {
                  Navigator.pop(context);
                } else if (value == 'option2') {
                  logout();
                } else if (value == 'option3') {
                  final Uri url = Uri.parse("piyushdev.developer@gmail.com");
                  launchUrl(url);
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'option1',
                    child: Text('All Users'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'option2',
                    child: Text('Log out'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'option3',
                    child: Text('Contact Developer'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              child: Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data?.docs ?? [];

                    if (documents.isEmpty) {
                      return const Center(
                        child: Text('No messages available'),
                      );
                    }

                    List<Widget> messageWidgets = [];
                    for (var message in documents.reversed) {
                      final messageText = message.get('text') as String? ?? '';
                      final sendBY = message.get("send by") as String? ?? "";
                      bool isCurrentUser = sendBY ==
                          FirebaseAuth.instance.currentUser?.displayName;

                      Widget messageWidget = Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            isCurrentUser
                                ? Expanded(
                                    child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 86, 7, 255),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(25.0),
                                          topRight: Radius.circular(25.0),
                                          bottomLeft: Radius.circular(25.0),
                                        ),
                                        border: Border.all(
                                          width: 2.0,
                                          color: const Color.fromARGB(
                                              255, 235, 235, 235),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(13.0),
                                        child: Text(
                                          messageText,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                                : Expanded(
                                    child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 226, 226, 226),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(25.0),
                                          bottomLeft: Radius.circular(25.0),
                                          bottomRight: Radius.circular(25.0),
                                        ),
                                        border: Border.all(
                                          width: 2.0,
                                          color: const Color.fromARGB(
                                              255, 236, 236, 236),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(13.0),
                                        child: Text(
                                          messageText,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      );

                      messageWidgets.add(messageWidget);
                    }

                    return ListView(
                      reverse: true,
                      children: messageWidgets,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      // onChanged: handleChanged,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
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
      ),
    );
  }
}
