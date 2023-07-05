import 'package:chating_app/constants.dart';
import 'package:chating_app/screens/conversion_screen.dart';
import 'package:chating_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {

  static String id = 'splash screen';

   SplashScreen({super.key});

   FirebaseAuth currentUser = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {

    Future.delayed(
      const Duration(milliseconds: 500,) ,
          ()
      {

        if(currentUser.currentUser != null){

          Navigator.pushReplacementNamed(context, ConversionScreen.id);
          //print('user is exist');
        }else{

          Navigator.pushReplacementNamed(context, LoginScreen.id);
          //print('user is not exist');
        }

      },
    );
    return Scaffold(
      backgroundColor: kPrimaryColor,

      // building splash screen ui
      body:  Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/chat_icon.png' ,
              width: 180,
              height: 180,

            ),

            const Text(
              kAppName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'Pacifico',
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ) ,
    );


  }

}
