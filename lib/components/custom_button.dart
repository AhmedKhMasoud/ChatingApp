import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  String buttonText;
  VoidCallback? onPressed;
  CustomButton({ this.onPressed,required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusDirectional.circular(6),
      ),
      width: double.infinity,
      height: 55,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: const TextStyle(
            color: Color(0xff2A465E),
            fontSize: 20,
          ),

        ),
      ),
    );
  }
}
