import 'package:chatting_app/components/if_logged_in.dart';
import 'package:chatting_app/pages/on_users_list.dart';
import 'package:chatting_app/pages/chat_screen.dart';
import 'package:chatting_app/pages/create_account.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => IfLoggedIn(),
      "/signup": (context) => const CreateAccount(),
      "/home": (context) => const ChatScreen(),
      "/users": (context) => const OnlineUsersScreen(),
    },
    title: "Chatting App",
  ));
}
// ARE YUO IN PERIODS?