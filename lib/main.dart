import 'package:chating_app/screens/chat_screen.dart';
import 'package:chating_app/screens/conversion_screen.dart';
import 'package:chating_app/screens/signup_screen.dart';
import 'package:chating_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chating_app/screens/login_screen.dart';

import 'firebase_options.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( ChattingApp());
}


class ChattingApp extends StatelessWidget {
  const ChattingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: SplashScreen.id ,
      routes:
      {
        SplashScreen.id : (context) => SplashScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        SignUpScreen.id : (context) =>SignUpScreen() ,
        ChatScreen.id : (context) =>ChatScreen(),
        ConversionScreen.id : (context) => ConversionScreen(),
      },


    );
  }
}



