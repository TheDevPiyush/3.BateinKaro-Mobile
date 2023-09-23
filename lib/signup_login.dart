// ignore_for_file: use_build_context_synchronously
import 'package:chatting_app/components/alert_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future login(String emailAddress, String password, BuildContext context) async {
  try {
    User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    ))
        .user;

    if (user != null) {
      Navigator.pushReplacementNamed(context, "/intro");
      return user;
    } else {
      CustomDialog(
        title: 'Could not login',
        content: 'Faced an issue while logging in. Try again.',
      ).show(context);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      CustomDialog(
        title: "User Not Found",
        content: "No user is available for that email address.",
      ).show(context);
    } else if (e.code == 'wrong-password') {
      CustomDialog(
        title: "Wrong Password",
        content: "You have entered wrong password for that account.",
      ).show(context);
    }
  }
}

Future signUp(String emailAddress, String password, String name,
    BuildContext context) async {
  try {
    User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailAddress,
      password: password,
    ))
        .user;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .set({
        "name": name,
        "email": emailAddress,
        "status": "UA",
        "token": "",
      });
      user.updateDisplayName(name);
      CustomDialog(
        title: "Sign Up Success",
        content: "You account was set up successfully. You can sign in now.",
      ).show(context);

      return user;
    } else {
      CustomDialog(
        title: "Sign Up Error",
        content: "Sign Up failed. Try again.",
      ).show(context);
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      CustomDialog(
        title: "Weak Password",
        content: "The password provided is too weak.",
      ).show(context);
    } else if (e.code == 'email-already-in-use') {
      CustomDialog(
        title: "Email Already Registered",
        content: "An account for that email already exists.",
      ).show(context);
    }
  } catch (e) {
    CustomDialog(
            title: "Server Error",
            content:
                "There seems to be some problem with the server. Try again after some time.")
        .show(context);
  }
}

Future signout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut().then(
          (value) => {
            Navigator.pushReplacementNamed(context, '/'),
          },
        );
  } catch (e) {
    CustomDialog(title: "Error", content: "Problem in Signing Out. Try Again.")
        .show(context);
  }
}
