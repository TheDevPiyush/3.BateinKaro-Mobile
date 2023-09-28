// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatting_app/components/alert_box.dart';
import 'package:chatting_app/components/appbar_on_users.dart';
import 'package:chatting_app/components/button.dart';
import 'package:chatting_app/components/loading_alert.dart';
import 'package:chatting_app/pages/full_screen_image.dart';
import 'package:chatting_app/signup_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final Function ontapFunc;
  const ChatScreen({super.key, required this.ontapFunc});

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
    LoadingAlert.show(context);
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
        await sendNotificationUsingPostmanAPI(
          FirebaseAuth.instance.currentUser?.displayName ?? "Message",
          '${FirebaseAuth.instance.currentUser?.displayName ?? "Message -"} Sent you a picture.',
        );
        setState(() {
          imageUpload = false;
        });
        LoadingAlert.hide(context);
      });
    } catch (e) {
      setState(() {
        imageUpload = false;
        Navigator.pop(context);
      });
      LoadingAlert.hide(context);

      CustomDialog(
              title: "Error Uploading",
              content: "There was some error uploading the file. Try again")
          .show(context);
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
      await sendNotificationUsingPostmanAPI(
        FirebaseAuth.instance.currentUser?.displayName.toString() ?? "Message",
        messageText,
      );
    }
  }

  @override
  void initState() {
    online();
    WidgetsBinding.instance.addObserver(this);
    TokenUpdate();
    super.initState();
  }

  // ignore: non_constant_identifier_names
  TokenUpdate() async {
    await FirebaseMessaging.instance.getToken().then(
      (value) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({"token": value});
      },
    );
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"token": fcmToken});
    }).onError((err) {
      // Error getting token.
    });
  }

  Future<void> sendNotificationUsingPostmanAPI(
      String title, String body) async {
    const serverKey =
        'AAAAfFLo64I:APA91bHPoI_j94WR7l0lDmDPpIeisTdybob-fmrpHZelEKoJu5P477D_2BCJwoRfMQKtuOlWxrgcOq5y5TTkFNIawO9O172SCg9L-kf9Ba5o9tU5QzilbI60eMKzbwniQpQRvy73Zj8w'; // Replace with your FCM server key
    final tokens = await getFCMTokensFromFirestore();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final data = {
      'registration_ids': tokens,
      'notification': {
        'title': title,
        'body': body,
      },
    };

    const url = 'https://fcm.googleapis.com/fcm/send';

    // ignore: unused_local_variable
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(data),
    );
  }

  Future<List<String>> getFCMTokensFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final usersCollection = firestore.collection('users');

    final QuerySnapshot usersSnapshot = await usersCollection.get();
    final List<String> tokens = [];

    for (var userDoc in usersSnapshot.docs) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData.containsKey('token')) {
        final String userToken = userData['token'];
        tokens.add(userToken);
      }
    }

    return tokens;
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
    Navigator.pop(context, "OK");
  }

  _sendingMails() async {
    var url = Uri.parse("mailto:piyushdev.developer@gmail.com");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      CustomDialog(
              title: "Email app not found",
              content: "Reach me :\npiyushdev.developer@gmail.com")
          .show(context);
    }
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
                  widget.ontapFunc();
                } else if (value == 'option2') {
                  _sendingMails();
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
                        Text(
                          'All Users',
                        ),
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
                      DateFormat dateFormat = DateFormat('hh:mm a dd-MM-yyyy');
                      String formattedTime = dateFormat.format(dateTime);

                      Widget messageWidget = InkWell(
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
                                            InkWell(
                                              onDoubleTap: () {
                                                showCupertinoDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CupertinoAlertDialog(
                                                      title: const Text(
                                                          "Delete this message for everyone?"),
                                                      content: Text(
                                                        messageText,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      actions: <Widget>[
                                                        CupertinoDialogAction(
                                                          child: const Text(
                                                              "Cancel"),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        CupertinoDialogAction(
                                                          child:
                                                              const Text("OK"),
                                                          onPressed: () {
                                                            deleteMessage(id);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
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
                                                        ? InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                      MaterialPageRoute<
                                                                          void>(
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return FullScreenImagePage(
                                                                      imageUrl:
                                                                          messageText);
                                                                },
                                                              ));
                                                            },
                                                            child: FadeInImage(
                                                              imageErrorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return GestureDetector(
                                                                  onTap: () {
                                                                    launchUrl(
                                                                      Uri.parse(
                                                                          messageText),
                                                                    );
                                                                  },
                                                                  child:
                                                                      SelectableText(
                                                                    messageText,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              placeholder:
                                                                  const AssetImage(
                                                                "images/loading-gif.gif",
                                                              ),
                                                              image: NetworkImage(
                                                                  messageText),
                                                            ),
                                                          )
                                                        : SelectableText(
                                                            messageText,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
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
                                                        imageErrorBuilder:
                                                            (context, error,
                                                                stackTrace) {
                                                          return SelectableText(
                                                            messageText,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 17,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          );
                                                        },
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
