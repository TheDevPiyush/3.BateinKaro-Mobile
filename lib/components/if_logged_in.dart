import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IfLoggedIn extends StatefulWidget {
  const IfLoggedIn({super.key});

  @override
  State<IfLoggedIn> createState() => _IfLoggedInState();
}

class _IfLoggedInState extends State<IfLoggedIn> {
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, "/intro");
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, "/login");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: const Color.fromRGBO(31, 15, 83, 1),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            "images/logo-color.png",
            scale: 5,
          ),
        ),
      ),
    );
  }
}
