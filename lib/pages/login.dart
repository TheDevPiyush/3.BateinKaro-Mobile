import 'package:chatting_app/components/button.dart';
import 'package:chatting_app/components/textfield.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

TextEditingController controllerEmail = TextEditingController();
TextEditingController controllerPassword = TextEditingController();

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
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
                child: Container(
                  height: size.height * 0.65,
                  width: size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(-7, 10),
                            blurRadius: 33,
                            blurStyle: BlurStyle.outer)
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SizedBox(
                      //   height: size.height * 0.02,
                      // ),
                      const Text(
                        "Sign In",
                        style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1),
                      ),
                      // SizedBox(
                      //   height: size.height * 0.01,
                      // ),
                      const Text(
                        "Sign into your account!",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 129, 129, 129),
                            letterSpacing: 1),
                      ),
                      // SizedBox(
                      //   height: size.height * 0.05,
                      // ),
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
                              style: TextStyle(fontWeight: FontWeight.w400),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CustomButton(text: "Sign In"),
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
