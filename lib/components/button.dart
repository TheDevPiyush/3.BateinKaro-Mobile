import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function? ontap;

  const CustomButton({
    super.key,
    required this.text,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        print("Clicked");
        FocusScope.of(context).unfocus();
      },
      child: Container(
        width: 150,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.blueAccent[700],
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(27),
              right: Radius.circular(27),
            )),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ),
    );
  }
}
