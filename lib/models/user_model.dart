
import 'package:chating_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  String email;
  String name;
  String userId;

  UserModel({
    required this.email ,
    required this.name,
    required this.userId,
  });



  factory UserModel.fromJson(jsonData){

    return UserModel(
        email: jsonData[kEmail] ,
        name: jsonData[kName]  ,
        userId: jsonData[kUserId],

    );
  }

}