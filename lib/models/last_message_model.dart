import 'package:chating_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LastMessageModel{

  String lastMessage;
  Timestamp time;
  String senderID;
  String userID;
  bool isSeen;

  LastMessageModel(
      {
        required this.lastMessage ,
        required this.time,
        required this.senderID,
        required this.userID,
        required this.isSeen,
      }
      );


  factory LastMessageModel.fromJson(jsonData){

    return LastMessageModel(
      lastMessage: jsonData[kLastMessage],
      time: jsonData[kSendAt],
      senderID: jsonData[kSenderMessage],
      userID : jsonData[kUserId],
      isSeen: jsonData[kMessageIsSeen],
    );
  }



}