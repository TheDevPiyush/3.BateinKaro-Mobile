import 'package:chatting_app/components/if_logged_in.dart';
import 'package:chatting_app/pages/login.dart';
import 'package:chatting_app/pages/pageview.dart';
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
      "/": (context) => const IfLoggedIn(),
      "/signup": (context) => const CreateAccount(),
      "/intro":(context) => const IntroPage(),
      "/login":(context) => const Login(),
    },
    title: "Chatting App",
  ));
}
