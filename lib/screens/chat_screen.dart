import 'package:chating_app/components/custom_chat_friend_message.dart';
import 'package:chating_app/components/custom_chat_message_design.dart';
import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget{

  static const id = ' chat Screen';


  // variables
   String? messageData;
   dynamic userId ;
   String currentId = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController controller = TextEditingController();

  ScrollController scrollController = ScrollController();

  // variables for firebase
  CollectionReference? messagesCollection ;

  @override
  Widget build(BuildContext context) {

    // receiving the user id from previous screen
    userId = ModalRoute
        .of(context)!
        .settings
        .arguments;


    return Scaffold(
      appBar: appBarUi(context),
      body: Column(
        children: [

          // design the list view which contain the messages
          Expanded(
            child: buildStream(),
          ),

          // function contain the text form field which response to send messages
          customSendMessageTextFormField(),
        ],
      ),
    );




  }


  // get the chat data from fire store
  Widget buildStream() {

    return StreamBuilder<QuerySnapshot> (

      // check if this doc has the data or the other
      stream: FirebaseFirestore.instance.collection('$kMessagesCollection/$currentId$userId/$kMessagesCollection')
          .orderBy(kSendAt, descending: true)
          .snapshots(),

      builder: (context , snapshot){

        // if the collection has data
        try{
          if(snapshot.data!.size > 0 ){

            return buildStreamUi('$kMessagesCollection/$currentId$userId/$kMessagesCollection');

          }

          // if the collection has no data yet
          else{

            return buildStreamUi('$kMessagesCollection/$userId$currentId/$kMessagesCollection');

          }
        }
        catch(e){
          print('ERROR: $e');
        }

        return const Center(child: Text('Loading'));

      },

    );


  }

  Widget buildStreamUi(String stream){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance.collection(stream)
          .orderBy(kSendAt, descending: true)
          .snapshots(),

      builder: (context , snapshot){

        // if the collection has data
        if(snapshot.hasData){

          List<MessageModel> msgList = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            msgList.add(MessageModel.fromJson(snapshot.data!.docs[i]));
          }

          return chatUiIfHasMessages(msgList);

        }

        // if the collection has no data yet
        else{
          return chatUiIfNoMessages();

        }


      },

    );

  }

  // function called to build chat screen ui
  Widget chatUiIfHasMessages(List<MessageModel> list) =>
      ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: list.length,
          itemBuilder: (context, index) {

            // check from message
            // is from me
            // or from the other user
            return list[index].senderMessage == currentId
                ? CustomChatMessageDesign(messages: list[index])
                : CustomChatFriendMessage(messages: list[index]);
          });

  // function called to build chat screen ui if no messages yet
  Widget chatUiIfNoMessages() => Container(
        alignment: Alignment.center,
        child: const Text(
          'tap to start chat.',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      );

  // build the text field which send message
  Widget customSendMessageTextFormField() => Container(
    margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 20, vertical: 15),
    child: TextField(
      controller: controller,

      onChanged: (data) {
        messageData = data;
      },
      // when click submit from keyboard
      onSubmitted: (data) {
        // save the data in fire store
        saveMessageData(data);

        // used to clear text in text field
        clearMessageTextAndScrollDown();
      },

      decoration: InputDecoration(
        hintText: 'type a message',
        suffixIcon: IconButton(
          // when click submit from icon
          onPressed: () {
            saveMessageData(messageData!);

            // used to clear text in text field
            clearMessageTextAndScrollDown();
          },
          icon: const Icon(
            Icons.send,
            color: kPrimaryColor,
          ),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
      ),
    ),
  );

  // used to clear text in text field
  void clearMessageTextAndScrollDown() {
    controller.clear();

    scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
  }

  // function called to save message in fire store
  Future saveMessageData(String data) async {
    // save message once for me

    // to check if the document id saved by this user or the other user
    await FirebaseFirestore.instance.collection('messages/$currentId$userId/messages')
        .get().then((value) {

          // this if it save for this user

      try{
        if(value.size !=0){

          FirebaseFirestore.instance
              .collection(kMessagesCollection)
              .doc('$currentId$userId')
              .collection(kMessagesCollection).add({
            kMessage: data.toString(),
            kSenderMessage: currentId,
            kReceiverMessage: userId,
            kSendAt: Timestamp.now(),
            kMessageIsSeen: false,});

        }
        // this if it save for other user
        else{
          FirebaseFirestore.instance
              .collection(kMessagesCollection)
              .doc('$userId$currentId')
              .collection(kMessagesCollection).add({
            kMessage: data.toString(),
            kSenderMessage: currentId,
            kReceiverMessage: userId,
            kSendAt: Timestamp.now(),
            kMessageIsSeen: false,});

        }

      }catch(e){
        print('ERROR: $e');
      }



    });

    // update and save the last message
    await updateLastMessage(data);


  }

  // function to update and save the last message
  Future<void> updateLastMessage(String data) async {
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection('conversion')
        .doc(userId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: userId,
      kMessageIsSeen : true,
    });

    // update and save the last message for friend
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .collection('conversion')
        .doc(currentId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: currentId,
      kMessageIsSeen : false,
    });
  }


// function called to build chat screen app bar ui
PreferredSizeWidget appBarUi(BuildContext context) =>
      AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kPrimaryColor,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app bar image
              Image.asset(
                kAppLogo,
                width: 40,
                height: 40,
              ),
              // app bar text
              const Text('Chat'),
            ],
          ),
        ),
      );

}

//old
/*
import 'package:chating_app/components/custom_chat_friend_message.dart';
import 'package:chating_app/components/custom_chat_message_design.dart';
import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget {

  static const id = ' chat Screen';

  // constructor
  ChatScreen({super.key});

  // variables
  String? messageData;
  var userId;
  var currentId;

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  // variables for firebase
  CollectionReference? messagesCollection ;

  @override
  Widget build(BuildContext context) {

    // receiving the user id from previous screen
    userId = ModalRoute
        .of(context)!
        .settings
        .arguments;
    // passing the current user id
    currentId = FirebaseAuth.instance.currentUser!.uid;

    // initialize the fire store collection
    messagesCollection = FirebaseFirestore.instance
        .collection('$kMessagesCollection/$currentId/$kMessagesCollection/$userId/$kMessagesCollection');

    return Scaffold(
      appBar: buildAppBarUi(context),
      body: Column(
        children: [

          // design the list view which contain the messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: messagesCollection!
                  .orderBy(kSendAt, descending: true)
                  .snapshots(),

              builder: (context , snapshot){

                // if the collection has data
                if(snapshot.hasData){

                  List<MessageModel> msgList = [];

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    msgList.add(MessageModel.fromJson(snapshot.data!.docs[i]));
                  }

                  return buildChatUiIfHasMessages(msgList);

                }

                // if the collection has no data yet
                else{
                  return buildChatUiIfNoMessages();

                }


              },

            ),
          ),

          // function contain the text form field which response to send messages
          buildSendMessageTextFormField(),
        ],
      ),
    );


  }

  // function called to build chat screen app bar ui
  PreferredSizeWidget buildAppBarUi(BuildContext context) =>
      AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kPrimaryColor,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app bar image
              Image.asset(
                kAppLogo,
                width: 40,
                height: 40,
              ),
              // app bar text
              const Text('Chat'),
            ],
          ),
        ),
      );

  // function called to build chat screen ui
  Widget buildChatUiIfHasMessages(List<MessageModel> list) =>
      ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: list.length,
          itemBuilder: (context, index) {

            // check from message
            // is from me
            // or from the other user
            return list[index].senderMessage == currentId
                ? CustomChatMessageDesign(messages: list[index])
                : CustomChatFriendMessage(messages: list[index]);
          });

  // function called to build chat screen ui if no messages yet
  Widget buildChatUiIfNoMessages() => Container(
        alignment: Alignment.center,
        child: const Text(
          'tap to start chat.',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      );

  // build the text field which send message
  Widget buildSendMessageTextFormField() => Container(
    margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 20, vertical: 15),
    child: TextField(
      controller: controller,

      onChanged: (data) {
        messageData = data;
      },
      // when click submit from keyboard
      onSubmitted: (data) {
        // save the data in fire store
        saveMessageData(data);

        // used to clear text in text field
        clearMessageTextAndScrollDown();
      },

      decoration: InputDecoration(
        hintText: 'type a message',
        suffixIcon: IconButton(
          // when click submit from icon
          onPressed: () {
            saveMessageData(messageData!);

            // used to clear text in text field
            clearMessageTextAndScrollDown();
          },
          icon: const Icon(
            Icons.send,
            color: kPrimaryColor,
          ),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
      ),
    ),
  );

  // used to clear text in text field
  // used to display last message in list view after sending message
  void clearMessageTextAndScrollDown() {
    controller.clear();

    scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.easeIn);
  }

  // function called to save message in fire store
  // update the data in current user
  Future saveMessageData(String data) async {
    // save message once for me
    await messagesCollection!.add({
      kMessage: data.toString(),
      kSenderMessage: currentId,
      kReceiverMessage: userId,
      kSendAt: Timestamp.now(),
      kMessageIsSeen: false,});


    // save message once for user
    await FirebaseFirestore.instance
        .collection('$kMessagesCollection/$userId/$kMessagesCollection/$currentId/$kMessagesCollection')
        .add({
      kMessage: data.toString(),
      kSenderMessage: currentId,
      kReceiverMessage: userId,
      kSendAt: Timestamp.now(),
      kMessageIsSeen: false,
    });

    // update and save the last message
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection('conversion')
        .doc(userId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: userId,
      kMessageIsSeen : true,
    });

    // update and save the last message for friend
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .collection('conversion')
        .doc(currentId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: currentId,
      kMessageIsSeen : false,
    });


  }

}


 */

/*
import 'package:chating_app/components/custom_chat_friend_message.dart';
import 'package:chating_app/components/custom_chat_message_design.dart';
import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget{

  static const id = ' chat Screen';


  // variables
   String? messageData;
   dynamic userId;
   String currentId = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController controller = TextEditingController();

  ScrollController scrollController = ScrollController();

  // variables for firebase
  CollectionReference? messagesCollection ;

  @override
  Widget build(BuildContext context) {

    // receiving the user id from previous screen
    userId = ModalRoute
        .of(context)!
        .settings
        .arguments;


    // initialize the fire store collection
    messagesCollection = FirebaseFirestore.instance
        .collection('$kMessagesCollection/$currentId/$kMessagesCollection/$userId/$kMessagesCollection');

    return Scaffold(
      appBar: appBarUi(context),
      body: Column(
        children: [

          // design the list view which contain the messages
          Expanded(
            child: buildStream(),
          ),

          // function contain the text form field which response to send messages
          customSendMessageTextFormField(),
        ],
      ),
    );


  }

  // function called to build chat screen app bar ui
  PreferredSizeWidget appBarUi(BuildContext context) =>
      AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kPrimaryColor,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app bar image
              Image.asset(
                kAppLogo,
                width: 40,
                height: 40,
              ),
              // app bar text
              const Text('Chat'),
            ],
          ),
        ),
      );


  Widget buildStream() {


    return StreamBuilder<QuerySnapshot> (

      // check if this doc has the data or the other
      stream: FirebaseFirestore.instance.collection('$kMessagesCollection/$currentId$userId/$kMessagesCollection')
          .orderBy(kSendAt, descending: true)
          .snapshots(),

      builder: (context , snapshot){

        // if the collection has data
        if(snapshot.data!.docs.length !=0){

          print('data is exist ${snapshot.data!.docs.length}');

          return buildStreamUi('$kMessagesCollection/$currentId$userId/$kMessagesCollection');

        }

        // if the collection has no data yet
        else{

          print('data is not exist ${snapshot.data!.docs.length}');
          return buildStreamUi('$kMessagesCollection/$userId$currentId/$kMessagesCollection');

        }


      },

    );


  }

  Widget buildStreamUi(String stream){

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance.collection(stream)
          .orderBy(kSendAt, descending: true)
          .snapshots(),

      builder: (context , snapshot){

        // if the collection has data
        if(snapshot.hasData){

          List<MessageModel> msgList = [];

          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            msgList.add(MessageModel.fromJson(snapshot.data!.docs[i]));
          }

          return chatUiIfHasMessages(msgList);

        }

        // if the collection has no data yet
        else{
          return chatUiIfNoMessages();

        }


      },

    );

  }

  // function called to build chat screen ui
  Widget chatUiIfHasMessages(List<MessageModel> list) =>
      ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: list.length,
          itemBuilder: (context, index) {

            // check from message
            // is from me
            // or from the other user
            return list[index].senderMessage == currentId
                ? CustomChatMessageDesign(messages: list[index])
                : CustomChatFriendMessage(messages: list[index]);
          });

  // function called to build chat screen ui if no messages yet
  Widget chatUiIfNoMessages() => Container(
        alignment: Alignment.center,
        child: const Text(
          'tap to start chat.',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      );

  // build the text field which send message
  Widget customSendMessageTextFormField() => Container(
    margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 20, vertical: 15),
    child: TextField(
      controller: controller,

      onChanged: (data) {
        messageData = data;
      },
      // when click submit from keyboard
      onSubmitted: (data) {
        // save the data in fire store
        saveMessageData(data);

        // used to clear text in text field
        clearMessageTextAndScrollDown();
      },

      decoration: InputDecoration(
        hintText: 'type a message',
        suffixIcon: IconButton(
          // when click submit from icon
          onPressed: () {
            saveMessageData(messageData!);

            // used to clear text in text field
            clearMessageTextAndScrollDown();
          },
          icon: const Icon(
            Icons.send,
            color: kPrimaryColor,
          ),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
      ),
    ),
  );

  // used to clear text in text field
  void clearMessageTextAndScrollDown() {
    controller.clear();

    scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.easeIn);
  }

  // function called to save message in fire store
  Future saveMessageData(String data) async {
    // save message once for me

    // to check if the document id saved by this user or the other user
    await FirebaseFirestore.instance.collection('messages/$currentId$userId/messages')
        .get().then((value) {

          // this if it save for this user

      try{
        if(value.size !=0){

          FirebaseFirestore.instance
              .collection(kMessagesCollection)
              .doc('$currentId$userId')
              .collection(kMessagesCollection).add({
            kMessage: data.toString(),
            kSenderMessage: currentId,
            kReceiverMessage: userId,
            kSendAt: Timestamp.now(),
            kMessageIsSeen: false,});

        }
        // this if it save for other user
        else{
          FirebaseFirestore.instance
              .collection(kMessagesCollection)
              .doc('$userId$currentId')
              .collection(kMessagesCollection).add({
            kMessage: data.toString(),
            kSenderMessage: currentId,
            kReceiverMessage: userId,
            kSendAt: Timestamp.now(),
            kMessageIsSeen: false,});

        }

      }catch(e){
        print('ERROR: $e');
      }



    });

    // update and save the last message
    await updateLastMessage(data);


  }

  // function to update and save the last message
  Future<void> updateLastMessage(String data) async {
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection('conversion')
        .doc(userId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: userId,
      kMessageIsSeen : true,
    });

    // update and save the last message for friend
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .collection('conversion')
        .doc(currentId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: currentId,
      kMessageIsSeen : false,
    });
  }


}


/*
import 'package:chating_app/components/custom_chat_friend_message.dart';
import 'package:chating_app/components/custom_chat_message_design.dart';
import 'package:chating_app/constants.dart';
import 'package:chating_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget {

  static const id = ' chat Screen';

  // constructor
  ChatScreen({super.key});

  // variables
  String? messageData;
  var userId;
  var currentId;

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  // variables for firebase
  CollectionReference? messagesCollection ;

  @override
  Widget build(BuildContext context) {

    // receiving the user id from previous screen
    userId = ModalRoute
        .of(context)!
        .settings
        .arguments;
    // passing the current user id
    currentId = FirebaseAuth.instance.currentUser!.uid;

    // initialize the fire store collection
    messagesCollection = FirebaseFirestore.instance
        .collection('$kMessagesCollection/$currentId/$kMessagesCollection/$userId/$kMessagesCollection');

    return Scaffold(
      appBar: buildAppBarUi(context),
      body: Column(
        children: [

          // design the list view which contain the messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: messagesCollection!
                  .orderBy(kSendAt, descending: true)
                  .snapshots(),

              builder: (context , snapshot){

                // if the collection has data
                if(snapshot.hasData){

                  List<MessageModel> msgList = [];

                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    msgList.add(MessageModel.fromJson(snapshot.data!.docs[i]));
                  }

                  return buildChatUiIfHasMessages(msgList);

                }

                // if the collection has no data yet
                else{
                  return buildChatUiIfNoMessages();

                }


              },

            ),
          ),

          // function contain the text form field which response to send messages
          buildSendMessageTextFormField(),
        ],
      ),
    );


  }

  // function called to build chat screen app bar ui
  PreferredSizeWidget buildAppBarUi(BuildContext context) =>
      AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: kPrimaryColor,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app bar image
              Image.asset(
                kAppLogo,
                width: 40,
                height: 40,
              ),
              // app bar text
              const Text('Chat'),
            ],
          ),
        ),
      );

  // function called to build chat screen ui
  Widget buildChatUiIfHasMessages(List<MessageModel> list) =>
      ListView.builder(
          reverse: true,
          controller: scrollController,
          itemCount: list.length,
          itemBuilder: (context, index) {

            // check from message
            // is from me
            // or from the other user
            return list[index].senderMessage == currentId
                ? CustomChatMessageDesign(messages: list[index])
                : CustomChatFriendMessage(messages: list[index]);
          });

  // function called to build chat screen ui if no messages yet
  Widget buildChatUiIfNoMessages() => Container(
        alignment: Alignment.center,
        child: const Text(
          'tap to start chat.',
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      );

  // build the text field which send message
  Widget buildSendMessageTextFormField() => Container(
    margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 20, vertical: 15),
    child: TextField(
      controller: controller,

      onChanged: (data) {
        messageData = data;
      },
      // when click submit from keyboard
      onSubmitted: (data) {
        // save the data in fire store
        saveMessageData(data);

        // used to clear text in text field
        clearMessageTextAndScrollDown();
      },

      decoration: InputDecoration(
        hintText: 'type a message',
        suffixIcon: IconButton(
          // when click submit from icon
          onPressed: () {
            saveMessageData(messageData!);

            // used to clear text in text field
            clearMessageTextAndScrollDown();
          },
          icon: const Icon(
            Icons.send,
            color: kPrimaryColor,
          ),
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: kPrimaryColor,
            )),
      ),
    ),
  );

  // used to clear text in text field
  // used to display last message in list view after sending message
  void clearMessageTextAndScrollDown() {
    controller.clear();

    scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.easeIn);
  }

  // function called to save message in fire store
  // update the data in current user
  Future saveMessageData(String data) async {
    // save message once for me
    await messagesCollection!.add({
      kMessage: data.toString(),
      kSenderMessage: currentId,
      kReceiverMessage: userId,
      kSendAt: Timestamp.now(),
      kMessageIsSeen: false,});


    // save message once for user
    await FirebaseFirestore.instance
        .collection('$kMessagesCollection/$userId/$kMessagesCollection/$currentId/$kMessagesCollection')
        .add({
      kMessage: data.toString(),
      kSenderMessage: currentId,
      kReceiverMessage: userId,
      kSendAt: Timestamp.now(),
      kMessageIsSeen: false,
    });

    // update and save the last message
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(currentId)
        .collection('conversion')
        .doc(userId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: userId,
      kMessageIsSeen : true,
    });

    // update and save the last message for friend
    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userId)
        .collection('conversion')
        .doc(currentId)
        .set({
      kLastMessage : data.toString(),
      kSendAt : Timestamp.now(),
      kSenderMessage : currentId,
      kUserId: currentId,
      kMessageIsSeen : false,
    });


  }

}


 */
 */