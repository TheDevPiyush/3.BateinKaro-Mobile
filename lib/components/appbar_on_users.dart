import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppBarOnlineUserList extends StatelessWidget {
  const AppBarOnlineUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'Online')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No online users');
        } else {
          final onlineUsers = snapshot.data?.docs;

          return Row(
            children: [
              for (var user in onlineUsers!)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Text(
                    FirebaseAuth.instance.currentUser?.uid == user.id
                        ? user["name"] + " (You),"
                        : (user["name"] + ","), // Assuming user id is the UID
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}
