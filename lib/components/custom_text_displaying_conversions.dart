import 'package:flutter/material.dart';

import '../models/last_message_model.dart';
import '../models/user_model.dart';


class CustomTextDisplayingConversions extends StatelessWidget {


  CustomTextDisplayingConversions(
      {
        required this.user ,
        required this.lastMessageModel,
        required this.onTap,
        required this.currentUserId,
        super.key});


  VoidCallback onTap;
  UserModel user;
  LastMessageModel lastMessageModel;
  String currentUserId;
  FontWeight fontWeight = FontWeight.normal;

  @override
  Widget build(BuildContext context) {

    return  GestureDetector(

      onTap: onTap,

      child: Row(
          children:
          [
            // to display image contain first letter of the name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8 , vertical: 16),
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 40,
                child: Text(
                  user.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [

                  // text display the name of friend
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  // text display last message
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 200,
                        child: Text(
                          '${lastMessageModel.lastMessage}' ,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: fontWeight,
                          ),
                        ),
                      ),

                      // circle for display if this message is seen or not
                      lastMessageModel.isSeen == false ? const Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 10),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 5,
                        ),
                      ) : const Text(''),
                    ],
                  ),
                ],
              ),
            ),


            // text display time
            lastMessageModel.lastMessage != 'tap to start message' ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${lastMessageModel.time.toDate().hour}:${lastMessageModel.time.toDate().minute}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ) : const Padding(
              padding:  EdgeInsets.all(8.0),
              child: Text(
                '00.00',
                style:  TextStyle(
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

