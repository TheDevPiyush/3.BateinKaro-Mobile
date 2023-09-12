import 'package:chatting_app/components/alert_box.dart';
import 'package:chatting_app/components/button.dart';
import 'package:chatting_app/components/textfield.dart';
import 'package:chatting_app/signup_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

TextEditingController controllerEmail = TextEditingController();
TextEditingController controllerPassword = TextEditingController();
bool isLoading = false;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _LoginState extends State<Login> {
  online() async {
    await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({"status": "Online"});
  }

  loginfunc() {
    FocusScope.of(context).unfocus();
    if (controllerEmail.text.isNotEmpty && controllerPassword.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      login(controllerEmail.text, controllerPassword.text, context)
          .then((user) => {
                if (user != null)
                  {
                    setState(() {
                      isLoading = false;
                      online();
                    })
                  }
                else
                  {
                    setState(() {
                      isLoading = false;
                    })
                  }
              });
    } else {
      CustomDialog(
              title: "Empty Field",
              content: "Make sure to fill all the fields.")
          .show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[500]!, Colors.purple[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: isLoading
                    // ignore: sized_box_for_whitespace
                    ? Container(
                        width: 45,
                        height: 45,
                        child: const CircularProgressIndicator(
                          strokeWidth: 8,
                        ),
                      )
                    : Container(
                        height: size.height * 0.7,
                        width: size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(-7, 10),
                                blurRadius: 33,
                              )
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "Sign In",
                              style: TextStyle(
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1),
                            ),
                            const Text(
                              "Sign into your account!",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 129, 129, 129),
                                  letterSpacing: 1),
                            ),
                            CustomTextField(
                                controller: controllerEmail,
                                hintText: "Email",
                                obscureText: false,
                                keyboard: TextInputType.emailAddress,
                                prefixIcon: Icons.email_rounded,
                                suffixicon: Icons.star),
                            CustomTextField(
                                controller: controllerPassword,
                                hintText: "Password",
                                obscureText: true,
                                keyboard: TextInputType.text,
                                prefixIcon: Icons.key_rounded,
                                suffixicon: Icons.star),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                15,
                                10,
                                15,
                                0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Don't have an account yet? ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/signup");
                                    },
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: CustomButton(
                                text: "Sign In",
                                ontap: loginfunc,
                              ),
                            )
                          ],
                        ),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
