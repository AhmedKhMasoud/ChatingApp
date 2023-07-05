import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:flutter/material.dart';

class CustomChatMessageDesign extends StatelessWidget {

   MessageModel messages ;

   CustomChatMessageDesign({required this.messages ,super.key});


  @override
  Widget build(BuildContext context) {


    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Container(
                decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius:   BorderRadiusDirectional.only  (
                      topStart:  Radius.circular(20),
                      topEnd :  Radius.circular(20),
                      bottomEnd :  Radius.circular(20),
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
              end: 25,
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

// the old design without time
/*
return Align(
alignment: Alignment.centerLeft,
child : Container(
decoration: const BoxDecoration(
color: kPrimaryColor,
borderRadius:   BorderRadiusDirectional.only  (
topStart:  Radius.circular(20),
topEnd :  Radius.circular(20),
bottomEnd :  Radius.circular(20),
),
),
padding: const EdgeInsetsDirectional.symmetric(horizontal: 20 , vertical: 25),
margin: const  EdgeInsetsDirectional.only(
top: 20,
start: 20,
end: 20,

),

child: const Text(
'hello there!' ,
style: TextStyle(
color: Colors.white,
),
),
),


);*/
