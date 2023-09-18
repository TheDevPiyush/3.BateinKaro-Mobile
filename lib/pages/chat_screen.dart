import 'dart:io';
import 'package:chatting_app/components/alert_box.dart';
import 'package:chatting_app/components/appbar_on_users.dart';
import 'package:chatting_app/components/button.dart';
import 'package:chatting_app/pages/full_screen_image.dart';
import 'package:chatting_app/signup_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ImagePicker picker = ImagePicker();
  File? image;
  String imagePathforupload = "";
  bool imageUpload = false;
  bool isLink = false;
  Future<void> imageModal() async {
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
        imagePathforupload = pickedImage.path;
        showModalFunc();
      });
    }
  }

  showModalFunc() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog.fullscreen(
        child: StatefulBuilder(
          builder: (context, StateSetter setState) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[500]!, Colors.purple[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 25,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 5, color: Colors.white),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: image != null
                          ? Image.file(image!)
                          : const Center(
                              child: Text("Image could not be selected.")),
                    ),
                  ),
                  CustomButton(
                    text: "Send",
                    ontap: () {
                      uploadImage(imagePathforupload);
                    },
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> uploadImage(String imagePath) async {
    setState(() {
      imageUpload = true;
      Navigator.pop(context);
    });
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference storageRef =
        storage.ref().child('images').child(image.toString());

    try {
      final UploadTask uploadTask = storageRef.putFile(File(imagePath));

      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();
        await _firestore.collection('messages').add({
          'text': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          "send by": FirebaseAuth.instance.currentUser?.displayName,
        });
        setState(() {
          imageUpload = false;
        });
      });
    } catch (e) {
      setState(() {
        imageUpload = false;
        Navigator.pop(context);
      });
      // ignore: use_build_context_synchronously
      CustomDialog(
              title: "Upload Cancelled",
              content:
                  "Image could not be completed. The reason might be imternal issue or your netword might be weak. Try Again.")
          .show(context);
    }
  }

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

  deleteMessage(id) async {
    await _firestore.collection('messages').doc(id).delete();
    // ignore: use_build_context_synchronously
    Navigator.pop(context, "OK");
  }

  @override
  Widget build(BuildContext context) {
    logout() {
      signout(context);
      offline();
    }

    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: const Color.fromARGB(255, 65, 0, 177),
          title: const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Gossip !",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                AppBarOnlineUserList(),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                if (value == 'option1') {
                  Navigator.pop(context);
                } else if (value == 'option2') {
                } else if (value == 'option3') {
                  logout();
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'option1',
                    child: Row(
                      children: [
                        Icon(Icons.group),
                        SizedBox(
                          width: 15,
                        ),
                        Text('All Users'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'option2',
                    child: Row(
                      children: [
                        Icon(Icons.email_rounded),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Contact Developer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'option3',
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined),
                        SizedBox(
                          width: 15,
                        ),
                        Text('Log Out'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[500]!, Colors.purple[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  stream: _firestore
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
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
                        child: Text(
                          'No messages available',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    List<Widget> messageWidgets = [];
                    for (var message in documents.reversed) {
                      // CHECK IF MESSAGE IS LINK OR NOT
                      final messageText = message.get('text') as String? ?? '';
                      if (Uri.parse(messageText).isAbsolute) {
                        isLink = true;
                      } else {
                        isLink = false;
                      }

                      String id = message.id;

                      final sendBY = message.get("send by") as String? ?? "";
                      bool isCurrentUser = sendBY ==
                          FirebaseAuth.instance.currentUser?.displayName;
                      final Timestamp time =
                          message.get("timestamp") ?? Timestamp.now();
                      DateTime dateTime = time.toDate();
                      DateFormat dateFormat = DateFormat('hh:mm a yy-MM-dd');
                      String formattedTime = dateFormat.format(dateTime);

                      Widget messageWidget = InkWell(
                        onDoubleTap: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: const Text(
                                    "Delete this message for everyone?"),
                                content: Text(
                                  messageText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      deleteMessage(id);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onTap: () {
                          final messageText =
                              message.get('text') as String? ?? '';
                          if (Uri.parse(messageText).isAbsolute) {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  return FullScreenImagePage(
                                      imageUrl: messageText);
                                },
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              isCurrentUser
                                  ? InkWell(
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                        ),
                                        alignment: Alignment.centerRight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "$sendBY (You)",
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromARGB(
                                                      255, 214, 214, 214)),
                                            ),
                                            Text(
                                              formattedTime,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromARGB(
                                                      255, 214, 214, 214)),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 98, 26, 255),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(35.0),
                                                  topRight:
                                                      Radius.circular(35.0),
                                                  bottomLeft:
                                                      Radius.circular(35.0),
                                                ),
                                                border: Border.all(
                                                  width: 2.0,
                                                  color: const Color.fromARGB(
                                                      255, 235, 235, 235),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(13),
                                                child: Container(
                                                  child: isLink
                                                      ? FadeInImage(
                                                          placeholder:
                                                              const AssetImage(
                                                            "images/loading-gif.gif",
                                                          ),
                                                          image: NetworkImage(
                                                              messageText),
                                                        )
                                                      : SelectableText(
                                                          messageText,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sendBY,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromARGB(
                                                    255, 214, 214, 214)),
                                          ),
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Color.fromARGB(
                                                    255, 214, 214, 214)),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 214, 3, 102),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(0.0),
                                                topRight: Radius.circular(35.0),
                                                bottomLeft:
                                                    Radius.circular(35.0),
                                                bottomRight:
                                                    Radius.circular(35.0),
                                              ),
                                              border: Border.all(
                                                width: 2.0,
                                                color: const Color.fromARGB(
                                                    255, 235, 235, 235),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(13),
                                              child: Container(
                                                child: isLink
                                                    ? FadeInImage(
                                                        placeholder:
                                                            const AssetImage(
                                                                "images/loading-gif.gif"),
                                                        image: NetworkImage(
                                                            messageText),
                                                      )
                                                    : SelectableText(
                                                        messageText,
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                            ],
                          ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                              color: Color.fromARGB(255, 189, 189, 189)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate),
                      onPressed: imageModal,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
