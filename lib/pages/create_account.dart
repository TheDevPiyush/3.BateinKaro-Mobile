import 'package:chatting_app/components/alert_box.dart';
import 'package:chatting_app/components/button.dart';
import 'package:chatting_app/components/textfield.dart';
import 'package:chatting_app/signup_login.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

TextEditingController controllerEmail = TextEditingController();
TextEditingController controllerPassword = TextEditingController();
TextEditingController controllerName = TextEditingController();
TextEditingController controllerPasswordConfirm = TextEditingController();

bool isLoading = false;

class _CreateAccountState extends State<CreateAccount> {
  signupfunc() {
    FocusScope.of(context).unfocus();
    if (controllerEmail.text.isNotEmpty &&
        controllerPassword.text.isNotEmpty &&
        controllerName.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      signUp(controllerEmail.text, controllerPassword.text, controllerName.text,
              context)
          .then((user) => {
                if (user != null)
                  {
                    setState(() {
                      isLoading = false;
                    })
                  }
                else
                  {
                    setState(() {
                      isLoading = false;
                    }),
                  }
              });
    } else {
      CustomDialog(
              title: "Empty Field",
              content: "Make sure you fill all the fields correctlt.")
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
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                child: isLoading
                    // ignore: sized_box_for_whitespace
                    ? Container(
                        width: 45,
                        height: 45,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
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
                                blurRadius: 35,
                              )
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  letterSpacing: 1),
                            ),
                            const Text(
                              "Let's create a account for you!",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 129, 129, 129),
                                  letterSpacing: 1),
                            ),
                            CustomTextField(
                                controller: controllerName,
                                hintText: "Name",
                                obscureText: false,
                                keyboard: TextInputType.name,
                                prefixIcon: Icons.email_rounded,
                                suffixicon: Icons.star),
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
                                suffixicon: Icons.remove_red_eye_rounded),
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
                                    "Want to sign in? ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(
                                          context, "/");
                                    },
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: CustomButton(
                                text: "Sign Up",
                                ontap: signupfunc,
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
