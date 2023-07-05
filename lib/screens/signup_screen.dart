import 'package:chating_app/components/custom_button.dart';
import 'package:chating_app/components/custom_text_form_field.dart';
import 'package:chating_app/helper/display_snackbar_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chating_app/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SignUpScreen extends StatefulWidget {

  static const id = 'signUp Screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {


  bool obScure = true;
  Icon suffixIcon = const Icon(Icons.visibility_off);

  // variable to save email and password data
  String? email , password , name;

  // variable to check the validation
  GlobalKey<FormState> keyForm = GlobalKey();

  // variable to check enable of modal progress
  bool isLoading = false;
  Timestamp time = Timestamp.now();
  @override
  Widget build(BuildContext context) {



    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,

        body: buildSignupUi(),
      ),
    );
  }



  // function called to design the sign up ui
  Widget buildSignupUi() => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Form(
        key: keyForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 200,
            ),

            // chatting app text
            const Text(
              'Chatting App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),

            // sign up text
            Container(
              width: double.infinity,
              child: const Text(
                textAlign: TextAlign.start,
                'sign up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // name text
            CustomTextFormField(
              prefixIcon: const Icon(Icons.person),
              labelText: 'Name',
              onChange: (data) {
                name = data;
              },
              keyboardType: TextInputType.text,
            ),

            const SizedBox(
              height: 10,
            ),
            // email text
            CustomTextFormField(
              prefixIcon: const Icon(Icons.email_outlined),
              labelText: 'E-mail',
              onChange: (data) {
                email = data;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(
              height: 10,
            ),
            // Password text
            CustomTextFormField(
              obscure: obScure,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: ()
                {

                  // check if password is obscure or not
                  if(obScure == true){

                    obScure = false;
                    suffixIcon = const Icon(Icons.visibility);

                  }else{

                    obScure = true;
                    suffixIcon = const  Icon(Icons.visibility_off);

                  }

                  setState(() {

                  });

                },
                icon: suffixIcon,
              ),
              labelText: 'Password',
              onChange: (data) {
                password = data;
              },
              keyboardType: TextInputType.visiblePassword,
            ),

            const SizedBox(
              height: 20,
            ),

            // sign up button
            CustomButton(
              onPressed: () async {
                // for signup with email and password
                await registerWithEmailAndPassword(context);
              },
              buttonText: 'sign up',
            ),

            const SizedBox(
              height: 10,
            ),
            // sign up text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'have an account ?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '  log in',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    ),
  );

  // function called to sign up with email and password
  Future<void> registerWithEmailAndPassword(BuildContext context) async {
    if (keyForm.currentState!.validate()) {

      // enable the modal progress
      loadModalProgressAndUpdateUi(enabled: true);
      try {

        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!);

        // called when user sign up successfully
        displaySnackBarMessage(context, 'Sign Up Success!');

        // save the data in fire store
        await  FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          kEmail : email,
          kName : name,
          kUserId :FirebaseAuth.instance.currentUser!.uid,
        });


        // to return to log in screen
        Navigator.pop(context);

        // check if there is an Exception
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          displaySnackBarMessage(context, 'invalid email format');
        } else if (e.code == 'email-already-in-use') {
          displaySnackBarMessage(context, 'E-mail is already exist');
        } else if (e.code == 'weak-password') {
          displaySnackBarMessage(
              context, 'Password should be at least 6 characters ');
        }
      }catch(e){
        displaySnackBarMessage(context, 'there is error, please try again later');
      }

      // disable the modal progress
      loadModalProgressAndUpdateUi(enabled: false);
    }
  }

  // function called to display modal progress and update the ui
  void loadModalProgressAndUpdateUi({required bool enabled}){

    isLoading = enabled;

    setState(() {});

  }
}
