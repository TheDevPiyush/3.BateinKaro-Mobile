import 'package:chatting_app/pages/create_account.dart';
import 'package:chatting_app/pages/home.dart';
import 'package:chatting_app/pages/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    routes: {
      "/": (context) => const Login(),
      "/signup": (context) => const CreateAccount(),
      "/home": (context) => const Home(),
    },
    title: "Chatting App",
  ));
}
