import 'package:chatting_app/components/button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnlineUsersScreen extends StatelessWidget {
  final Function ontapFunc;

  const OnlineUsersScreen({super.key, required this.ontapFunc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 65, 0, 177),
        title: const Text('Users'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[500]!, Colors.purple[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Expanded(
              child: OnlineUserList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CustomButton(
                  text: "Let's Gossip",
                  ontap: () {
                    ontapFunc();
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class OnlineUserList extends StatelessWidget {
  const OnlineUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
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
                for (var user in onlineUsers)
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FirebaseAuth.instance.currentUser?.uid == user.id
                            ? Text(
                                user["name"] + " - " + "You",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                user["name"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                        Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            color: Colors.green,
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ), // Assuming user id is the UID
                    subtitle: Text(
                      user['status'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 232, 232, 232),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],

              // Offline Users Section
              if (offlineUsers!.isNotEmpty) ...[
                for (var user in offlineUsers)
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(7)),
                            color: Colors.red,
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ), // Assuming user id is the UID
                    subtitle: Text(
                      user['status'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 231, 231, 231),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          );
        }
      },
    );
  }
}
