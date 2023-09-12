import 'package:chatting_app/components/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnlineUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: OnlineUserList(),
            ),
          ),
          CustomButton(
              text: "Let's Gossip",
              ontap: () {
                Navigator.pushNamed(context, "/home");
              })
        ],
      ),
    );
  }
}

class OnlineUserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No users');
        } else {
          final users = snapshot.data?.docs;

          // Split the users into online and offline
          final onlineUsers =
              users?.where((user) => user['status'] == 'Online').toList();
          final offlineUsers =
              users?.where((user) => user['status'] == 'Offline').toList();

          return ListView(
            children: [
              // Online Users Section
              if (onlineUsers!.isNotEmpty) ...[
                const Text('Online Users',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (var user in onlineUsers!)
                  ListTile(
                    title: FirebaseAuth.instance.currentUser?.uid == user.id  ? Text("You") : Text(user["name"]), // Assuming user id is the UID
                    subtitle: Text(user['status']),
                  ),
              ],

              // Offline Users Section
              if (offlineUsers!.isNotEmpty) ...[
                const Text('Offline Users',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                for (var user in offlineUsers)
                  ListTile(
                    title: Text(user["name"]), // Assuming user id is the UID
                    subtitle: Text(user['status']),
                  ),
              ],
            ],
          );
        }
      },
    );
  }
}
