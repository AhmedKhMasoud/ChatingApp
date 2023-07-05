
import 'package:chating_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {

  String message ;
  String senderMessage;
  String receiverMessage;
  Timestamp sendAt;
  bool isSeen;

  MessageModel({
    required this.message ,
    required this.senderMessage ,
    required this.receiverMessage,
    required this.sendAt,
    required this.isSeen,
  }
     );



  factory MessageModel.fromJson(jsonData){

    return MessageModel(
      message: jsonData[kMessage],
      senderMessage: jsonData[kSenderMessage],
      receiverMessage: jsonData[kReceiverMessage],
      sendAt: jsonData[kSendAt],
      isSeen: jsonData[kMessageIsSeen],
    );

  }

}