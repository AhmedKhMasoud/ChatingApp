import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:flutter/material.dart';

class CustomChatFriendMessage extends StatelessWidget {

  MessageModel messages ;

  CustomChatFriendMessage({required this.messages ,super.key});


  @override
  Widget build(BuildContext context) {


    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius:   BorderRadiusDirectional.only  (
                topStart:  Radius.circular(20),
                topEnd :  Radius.circular(20),
                bottomStart:  Radius.circular(20),
              ),
            ),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 35 , vertical: 25),
            margin: const  EdgeInsetsDirectional.only(
              top: 20,
              start: 20,
              end: 20,

            ),

            child:  Text(
              messages.message,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          // text for display time
          Container(
            margin: EdgeInsetsDirectional.only(
              start: 25,
              bottom: 5,
            ),
            child: Text(
              '${messages.sendAt.toDate().hour}:${messages.sendAt.toDate().minute}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );

  }
}