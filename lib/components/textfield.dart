import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboard;
  final IconData? eyeicon;
  final Function eyeFunc;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.obscureText,
    required this.keyboard,
    required this.eyeFunc,
    this.eyeicon,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboard,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: Icon(
                  widget.prefixIcon,
                ),
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              widget.eyeFunc();
            },
            icon: Icon(widget.eyeicon),
            iconSize: 20,
          )
        ],
      ),
    );
  }
}
