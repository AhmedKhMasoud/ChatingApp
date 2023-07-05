import 'package:chating_app/components/custom_text_displaying_conversions.dart';
import 'package:chating_app/models/last_message_model.dart';
import 'package:chating_app/models/user_model.dart';
import 'package:chating_app/screens/chat_screen.dart';
import 'package:chating_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';

class ConversionScreen extends StatefulWidget {
  static String id = 'home screen';

  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {

  bool isLoading = false;

  var currentId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference users =
      FirebaseFirestore.instance.collection(kUsersCollection);

  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child:getAllUsers(context) ,
    );
  }



  // for getting the users
  Widget getAllUsers(BuildContext screenContext) {
    return StreamBuilder(
      stream: users.snapshots(),
      builder: (context, snapshot) {

        String userName = '?';
        List<UserModel> userList = [];
        // check if there is a data in collection users or not
        if(snapshot.hasData){

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            if (snapshot.data!.docs[i][kUserId] != currentId) {
              userList.add(UserModel.fromJson(snapshot.data!.docs[i]));
            }

            else {
              userName = snapshot.data!.docs[i][kName];
            }

          }

          return getUsersLastMessage(userList, userName , screenContext);
        }

        // if no data exist
        return buildAppBarUi(userName);

      },
    );
  }

  //getting users Last Messages
  Widget getUsersLastMessage(List<UserModel> userList, String userName , BuildContext screenContext ) {
    return StreamBuilder(
        stream:
        users.doc(currentId).collection(kConversionCollection).snapshots(),
        builder: (context, snapshot) {
          List<LastMessageModel> lastMsgList = [];

          try{

            if (snapshot.hasData) {
              // loop for getting every user his last message
              for (int i = 0; i < userList.length; i++) {
                for (int x = 0; x < snapshot.data!.docs.length; x++) {
                  if (userList[i].userId == snapshot.data!.docs[x][kUserId]) {
                    lastMsgList
                        .add(LastMessageModel.fromJson(snapshot.data!.docs[x]));
                  }
                }
              }

              // check if user still has no message
              // then make his field empty until he send messages
              if (lastMsgList.length < userList.length) {
                for (int y = lastMsgList.length; y < userList.length; y++) {
                  lastMsgList.insert(
                      y,
                      LastMessageModel(
                          lastMessage: 'tap to start message',
                          time: Timestamp.now(),
                          senderID: '',
                          userID: '',
                          isSeen: true));
                }
              }

              return Scaffold(
                appBar: buildAppBarUi(userName),
                body: buildHomeUiIfHasUsers(userList, lastMsgList),
              );

            }
            // there is a users but still no message sent yet
            else {
              // check if user still has no message
              // then make his field empty until he send messages
              if (lastMsgList.length < userList.length) {
                for (int y = lastMsgList.length; y < userList.length; y++) {
                  lastMsgList.insert(
                      y,
                      LastMessageModel(
                          lastMessage: 'tap to start message',
                          time: Timestamp.now(),
                          senderID: '',
                          userID: '',
                          isSeen: true));
                }
              }

              return Scaffold(
                appBar: buildAppBarUi(userName),
                body: buildHomeUiIfHasUsers(userList, lastMsgList),
              );
            }

          }catch(e){
            print('ERROR 2 $e');
          }

          return Scaffold(
            appBar: buildAppBarUi(userName),
            body: buildHomeUiIfHasUsers(userList, lastMsgList),
          );


        });
  }

  // function called to build home screen ui
  Widget buildHomeUiIfHasUsers(
      List<UserModel> list, List<LastMessageModel> lastMsglist) {

    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return CustomTextDisplayingConversions(
          currentUserId: currentId,
          lastMessageModel: lastMsglist[index],
          user: list[index],
          onTap: () {
            // to set message is seen
            setMessageSeen(list, index);

            Navigator.pushNamed(context, ChatScreen.id,
                arguments: list[index].userId);
          },
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          width: double.infinity,
          height: 1,
          color: Colors.grey,
        );
      },
    );

  }

  // function to set message is seen
  void setMessageSeen(List<UserModel> list, int index) {
    FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection(kConversionCollection)
        .doc(list[index].userId)
        .update({
      kMessageIsSeen: true,
    });
  }
  // function to sign out
  Future<void> signOut(BuildContext context) async {
    setState(() {isLoading = true;});

    //setState(() {});
    await Future.delayed(
        const Duration(milliseconds: 200),
            ()
        {

        }
    );


    FirebaseAuth.instance.signOut();
    isLoading = false;
    Navigator.pushReplacementNamed(context, LoginScreen.id);
  }
  // function called to build home screen app bar ui
  PreferredSizeWidget buildAppBarUi( String name) =>
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        leadingWidth: 55,
        leading: Container(
          margin: const EdgeInsetsDirectional.only(start: 15),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              name[0],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // app bar image
            Image.asset(
              kAppLogo,
              width: 40,
              height: 40,
            ),
            // app bar text
            const Text('Conversion'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {

              setState(() {print('hi');isLoading = true;});

              //setState(() {});
              await Future.delayed(
                  const Duration(milliseconds: 200),
                      ()
                  {

                  }
              );


              FirebaseAuth.instance.signOut();
              isLoading = false;
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
            icon: const Icon(Icons.login_outlined),
          )
        ],
      );






}

// old
/*
import 'package:chating_app/components/custom_text_displaying_conversions.dart';
import 'package:chating_app/models/last_message_model.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:chating_app/models/user_model.dart';
import 'package:chating_app/screens/chat_screen.dart';
import 'package:chating_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';

class ConversionScreen extends StatefulWidget {

  static String id = 'home screen';

   ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {



  bool isLoading = false;

  var currentId;

  CollectionReference? users ;
  CollectionReference? lastMessages;


  @override
  Widget build(BuildContext context) {


    currentId = FirebaseAuth.instance.currentUser!.uid;
    users = FirebaseFirestore.instance.collection(kUsersCollection);




    return  ModalProgressHUD(
      inAsyncCall: isLoading,
      child: StreamBuilder(

          stream: users!
              .snapshots(),

          builder: (context, snapshot) {

            String userName='';
            List<UserModel> userList = [];
            // check if there is a data in collection users or not
            if (snapshot.data!.size != 0) {


              // loop for getting users from firebase collection
              for(int i=0 ; i<snapshot.data!.docs.length ; i++){

                if(snapshot.data!.docs[i][kUserId] != currentId){

                  userList.add(UserModel.fromJson(snapshot.data!.docs[i]));


                }else{
                  userName = snapshot.data!.docs[i][kName];
                }
              }


              return StreamBuilder(

                stream: users!.doc(currentId).collection(kConversionCollection)
                    .snapshots(),

                builder: (context, snapshot2) {

                  List<LastMessageModel> lastMsgList = [];

                  if(snapshot2.data!.size != 0){


                    // loop for getting every user his last message
                    for(int i=0 ; i<userList.length ; i++){

                      for(int x=0 ; x<snapshot2.data!.docs.length ; x++)
                      {

                        if(userList[i].userId == snapshot2.data!.docs[x][kUserId])
                        {
                          lastMsgList.add(LastMessageModel.fromJson(snapshot2.data!.docs[x]));
                        }
                      }

                    }

                    // check if user still has no message
                    // then make his field empty until he send messages
                    if(lastMsgList.length < userList.length){

                      for(int y=lastMsgList.length  ; y<userList.length ; y++){

                        lastMsgList.insert(y, LastMessageModel(
                            lastMessage: 'tap to start message',
                            time: Timestamp.now(),
                            senderID: '',
                            userID: '',
                            isSeen: true));

                      }


                    }


                   //print('dataaaaaaaaaa::: ${lastMsgList.length}');



                    return Scaffold(
                      appBar: buildAppBarUi(context , userName),
                      body: buildHomeUiIfHasUsers(userList , lastMsgList ),
                    );

                  }
                  ///////////////////////////////////////////
                  // there is a users but still no message sent yet
                  else {

                    // check if user still has no message
                    // then make his field empty until he send messages
                    if(lastMsgList.length < userList.length){

                      for(int y=lastMsgList.length  ; y<userList.length ; y++){

                        lastMsgList.insert(y, LastMessageModel(
                            lastMessage: 'tap to start message',
                            time: Timestamp.now(),
                            senderID: '',
                            userID: '',
                            isSeen: true));

                      }


                    }

                    return Scaffold(
                      appBar: buildAppBarUi(context , userName),
                      body: buildHomeUiIfHasUsers(userList , lastMsgList ),
                    );

                  }

                },
              );

            }


            ///////////////////////////////////////////
            else {
              return Scaffold(
                appBar: buildAppBarUi(context , userName),
              );
            }

          }),
    );


  }

  // function called to build home screen app bar ui
  PreferredSizeWidget buildAppBarUi(BuildContext context , String name ) => AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: kPrimaryColor,

    leadingWidth: 55,
    leading: Container(
      margin: EdgeInsetsDirectional.only(start: 15),
      child: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          name[0],
        ),
      ),
    ),

    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // app bar image
        Image.asset(
          kAppLogo,
          width: 40,
          height: 40,
        ),
        // app bar text
        const Text(
            'Conversion'
        ),
      ],
    ),

    actions: [
      IconButton(
        onPressed: ()
        async{
          isLoading = true;
          setState(() {

          });
          await Future.delayed(

              Duration(milliseconds: 200) ,
                  ()
              {

                try{
                  FirebaseAuth.instance.signOut();
                }catch(e){
                  print('e is:::: $e');
                }
              }
          ) ;

          isLoading = false;
          setState(() {

          });
          Navigator.pushReplacementNamed(context , LoginScreen.id);
        },
        icon: Icon(Icons.login_outlined),)
    ],
  );

  // function called to build home screen ui
  Widget buildHomeUiIfHasUsers(List<UserModel> list , List<LastMessageModel> lastMsglist ) =>ListView.separated(
    itemCount: list.length,

    itemBuilder: (context , index)
    {

      return CustomTextDisplayingConversions(
        currentUserId: currentId,
        lastMessageModel: lastMsglist[index],
        user: list[index],
        onTap: ()
        {

          // to set message is seen
          setMessageSeen(list, index);

          Navigator.pushNamed(context, ChatScreen.id , arguments: list[index].userId );

        },
      );

    },

    separatorBuilder: (context , index)
    {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 50),
        width: double.infinity,
        height: 1,
        color: Colors.grey,
      );
    },
  );

  // function to set message is seen
  void setMessageSeen(List<UserModel> list, int index) {
    FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection(kConversionCollection)
        .doc(list[index].userId)
        .update({
      kMessageIsSeen : true,
    });
  }

}


 */


/*
import 'package:chating_app/components/custom_text_displaying_conversions.dart';
import 'package:chating_app/models/last_message_model.dart';
import 'package:chating_app/models/user_model.dart';
import 'package:chating_app/screens/chat_screen.dart';
import 'package:chating_app/screens/login_screen.dart';
import 'package:chating_app/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';

class ConversionScreen extends StatefulWidget {
  static String id = 'home screen';

  ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  bool isLoading = false;

  var currentId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference users =
      FirebaseFirestore.instance.collection(kUsersCollection);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: getAllUsers(),
    );
  }

  // function called to build home screen app bar ui
  PreferredSizeWidget buildAppBarUi(BuildContext context, String name) =>
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        leadingWidth: 55,
        leading: Container(
          margin: EdgeInsetsDirectional.only(start: 15),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              name[0],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // app bar image
            Image.asset(
              kAppLogo,
              width: 40,
              height: 40,
            ),
            // app bar text
            const Text('Conversion'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {

              print('hello');
              isLoading = true;
              setState(() {});
              await Future.delayed(Duration(milliseconds: 1000), () {
                //FirebaseAuth.instance.signOut();
              });

              isLoading = false;
              setState(() {});
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
            icon: Icon(Icons.login_outlined),
          )
        ],
      );

  // function called to build home screen ui
  Widget buildHomeUiIfHasUsers(
          List<UserModel> list, List<LastMessageModel> lastMsglist) =>
      ListView.separated(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return CustomTextDisplayingConversions(
            currentUserId: currentId,
            lastMessageModel: lastMsglist[index],
            user: list[index],
            onTap: () {
              // to set message is seen
              setMessageSeen(list, index);

              Navigator.pushNamed(context, ChatScreen.id,
                  arguments: list[index].userId);
              //Navigator.pushNamed(context, ProfileScreen.id , arguments: list[index].userId );
            },
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            width: double.infinity,
            height: 1,
            color: Colors.grey,
          );
        },
      );

  // function to set message is seen
  void setMessageSeen(List<UserModel> list, int index) {
    FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection(kConversionCollection)
        .doc(list[index].userId)
        .update({
      kMessageIsSeen: true,
    });
  }

  // for getting the users
  Widget getAllUsers() {
    return StreamBuilder(
        stream: users!.snapshots(),
        builder: (context, snapshot) {
          String userName = '';

          List<UserModel> userList = [];

          // check if there is a data in collection users or not

          try{
            if (snapshot.hasData) {
              // loop for getting users from firebase collection
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                if (snapshot.data!.docs[i][kUserId] != currentId) {
                  userList.add(UserModel.fromJson(snapshot.data!.docs[i]));
                } else {
                  userName = snapshot.data!.docs[i][kName];
                }
              }

              return getUsersLastMessage(userList, userName);
            }
            // if no user yet
            else {
              return Scaffold(
                appBar: buildAppBarUi(context, userName),
              );
            }
          }
          catch(e){
            print('ERROR:: $e');
          }

          return Text('');

        });
  }

  //getting users Last Messages
  Widget getUsersLastMessage(List<UserModel> userList, String userName) {
    return StreamBuilder(
        stream:
            users!.doc(currentId).collection(kConversionCollection).snapshots(),
        builder: (context, snapshot) {
          List<LastMessageModel> lastMsgList = [];

          if (snapshot.hasData) {
            // loop for getting every user his last message
            for (int i = 0; i < userList.length; i++) {
              for (int x = 0; x < snapshot.data!.docs.length; x++) {
                if (userList[i].userId == snapshot.data!.docs[x][kUserId]) {
                  lastMsgList
                      .add(LastMessageModel.fromJson(snapshot.data!.docs[x]));
                }
              }
            }

            // check if user still has no message
            // then make his field empty until he send messages
            if (lastMsgList.length < userList.length) {
              for (int y = lastMsgList.length; y < userList.length; y++) {
                lastMsgList.insert(
                    y,
                    LastMessageModel(
                        lastMessage: 'tap to start message',
                        time: Timestamp.now(),
                        senderID: '',
                        userID: '',
                        isSeen: true));
              }
            }

            return Scaffold(
              appBar: buildAppBarUi(context, userName),
              body: buildHomeUiIfHasUsers(userList, lastMsgList),
            );
          }
          // there is a users but still no message sent yet
          else {
            // check if user still has no message
            // then make his field empty until he send messages
            if (lastMsgList.length < userList.length) {
              for (int y = lastMsgList.length; y < userList.length; y++) {
                lastMsgList.insert(
                    y,
                    LastMessageModel(
                        lastMessage: 'tap to start message',
                        time: Timestamp.now(),
                        senderID: '',
                        userID: '',
                        isSeen: true));
              }
            }

            return Scaffold(
              appBar: buildAppBarUi(context, userName),
              body: buildHomeUiIfHasUsers(userList, lastMsgList),
            );
          }
        });
  }
}

 */


/*
import 'package:chating_app/components/custom_app_bar.dart';
import 'package:chating_app/components/custom_text_displaying_conversions.dart';
import 'package:chating_app/models/last_message_model.dart';
import 'package:chating_app/models/user_model.dart';
import 'package:chating_app/screens/chat_screen.dart';
import 'package:chating_app/screens/login_screen.dart';
import 'package:chating_app/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';

class ConversionScreen extends StatefulWidget {
  static String id = 'home screen';

  ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {

  bool isLoading = false;

  var currentId = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference users =
      FirebaseFirestore.instance.collection(kUsersCollection);

  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child:getAllUsers() ,
    );
  }



  // for getting the users
  Widget getAllUsers() {
    return StreamBuilder(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          String userName = '';
          List<UserModel> userList = [];
          // check if there is a data in collection users or not
          try{
                  if(snapshot.hasData){
                    // loop for getting users from firebase collection
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      if (snapshot.data!.docs[i][kUserId] != currentId) {
                        userList.add(UserModel.fromJson(snapshot.data!.docs[i]));
                      }

                      else {
                        userName = snapshot.data!.docs[i][kName];
                      }

                    }

                    return Text('hello');
                    //return getUsersLastMessage(userList, userName );

                  }
                }catch(e){
                  print('ERROR IS: $e');

                  // if no user yet
                  return Scaffold(
                    appBar: buildAppBarUi( userName),
                  );

                }

          // if no user yet
          return Scaffold(
            appBar: buildAppBarUi( userName),
          );

        },
        );
  }

  //getting users Last Messages
  Widget getUsersLastMessage(List<UserModel> userList, String userName ) {
    return StreamBuilder(
        stream:
        users.doc(currentId).collection(kConversionCollection).snapshots(),
        builder: (context, snapshot) {
          List<LastMessageModel> lastMsgList = [];

          try{

            if (snapshot.hasData) {
              // loop for getting every user his last message
              for (int i = 0; i < userList.length; i++) {
                for (int x = 0; x < snapshot.data!.docs.length; x++) {
                  if (userList[i].userId == snapshot.data!.docs[x][kUserId]) {
                    lastMsgList
                        .add(LastMessageModel.fromJson(snapshot.data!.docs[x]));
                  }
                }
              }

              // check if user still has no message
              // then make his field empty until he send messages
              if (lastMsgList.length < userList.length) {
                for (int y = lastMsgList.length; y < userList.length; y++) {
                  lastMsgList.insert(
                      y,
                      LastMessageModel(
                          lastMessage: 'tap to start message',
                          time: Timestamp.now(),
                          senderID: '',
                          userID: '',
                          isSeen: true));
                }
              }

              return Scaffold(
                appBar: buildAppBarUi(userName),
                body: buildHomeUiIfHasUsers(userList, lastMsgList),
              );
            }
            // there is a users but still no message sent yet
            else {
              // check if user still has no message
              // then make his field empty until he send messages
              if (lastMsgList.length < userList.length) {
                for (int y = lastMsgList.length; y < userList.length; y++) {
                  lastMsgList.insert(
                      y,
                      LastMessageModel(
                          lastMessage: 'tap to start message',
                          time: Timestamp.now(),
                          senderID: '',
                          userID: '',
                          isSeen: true));
                }
              }

              return Scaffold(
                appBar: buildAppBarUi(userName),
                body: buildHomeUiIfHasUsers(userList, lastMsgList),
              );
            }

          }catch(e){
            print('ERROR 2 $e');
          }

          return Scaffold(
            appBar: buildAppBarUi(userName),
            body: buildHomeUiIfHasUsers(userList, lastMsgList),
          );

        });
  }

  // function called to build home screen app bar ui
  PreferredSizeWidget buildAppBarUi( String name) =>
      AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        leadingWidth: 55,
        leading: Container(
          margin: EdgeInsetsDirectional.only(start: 15),
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              name[0],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // app bar image
            Image.asset(
              kAppLogo,
              width: 40,
              height: 40,
            ),
            // app bar text
            const Text('Conversion'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {

              isLoading = true;
              setState(() {});
              await Future.delayed(
                  Duration(milliseconds: 200),
                      ()
                  {
                    FirebaseAuth.instance.signOut();
                  }
              );


              isLoading = false;
              Navigator.pushReplacementNamed(context, LoginScreen.id);
            },
            icon: Icon(Icons.login_outlined),
          )
        ],
      );

  // function called to build home screen ui
  Widget buildHomeUiIfHasUsers(
          List<UserModel> list, List<LastMessageModel> lastMsglist) {

    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return CustomTextDisplayingConversions(
          currentUserId: currentId,
          lastMessageModel: lastMsglist[index],
          user: list[index],
          onTap: () {
            // to set message is seen
            setMessageSeen(list, index);

            Navigator.pushNamed(context, ChatScreen.id,
                arguments: list[index].userId);
          },
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          width: double.infinity,
          height: 1,
          color: Colors.grey,
        );
      },
    );

  }


  // function to set message is seen
  void setMessageSeen(List<UserModel> list, int index) {
    FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection(kConversionCollection)
        .doc(list[index].userId)
        .update({
      kMessageIsSeen: true,
    });
  }


}


 */