import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData suffixicon;
  final bool obscureText;
  final TextInputType keyboard;

  const CustomTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.prefixIcon,
      required this.suffixicon,
      required this.obscureText,
      required this.keyboard});

  @override
  // ignore: library_private_types_in_public_api
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboard,
        decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(
              widget.prefixIcon,
            ),
            suffixIcon: Icon(
              widget.suffixicon,
              size: 15,
            )),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),
      ),
    );
  }
}
