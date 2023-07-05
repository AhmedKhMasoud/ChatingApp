import 'package:chating_app/components/custom_button.dart';
import 'package:chating_app/components/custom_text_form_field.dart';
import 'package:chating_app/constants.dart';
import 'package:chating_app/helper/display_snackbar_message.dart';
import 'package:chating_app/screens/conversion_screen.dart';
import 'package:chating_app/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {

  static const id = 'login Screen';
  static String? currentEmail ;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // variables to change edit in the text form field
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obScure = true;
  Icon suffixIcon = const Icon(Icons.visibility_off);

  // variables to save email and password
  String? email , password;

  // variable to check the validation
  GlobalKey<FormState> keyForm = GlobalKey();

  FirebaseAuth auth = FirebaseAuth.instance;

  // variable handle the modal progress hud
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,

        body: buildLoginUi(),
      ),
    );
  }

  // function called to design the login ui
  Widget buildLoginUi() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SingleChildScrollView(
      child: Form(
        key: keyForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            // app logo image
            const SizedBox(height: 100,),
            Image.asset(
              kAppLogo ,
              height: 150 ,
              width: 150,
            ),
            // chatting app text
            const Text(
              kAppName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pacifico',
              ),
            ),

            // login text
            Container(
              width: double.infinity,
              child:const Text(
                textAlign: TextAlign.start,
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 20,),
            // email text
            CustomTextFormField(
              controller: emailController,
              prefixIcon: const Icon(Icons.email_outlined),
              labelText: 'E-mail',
              onChange: (data){
                email = data;

              },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10,),
            // Password text
            CustomTextFormField(
              controller: passwordController,
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
                    suffixIcon = const Icon(Icons.visibility_off);

                  }

                  setState(() {

                  });

                },
                icon: suffixIcon,
              ),
              labelText: 'Password',
              onChange: (data){
                password = data;
              },
            ),

            const SizedBox(height: 20,),
            // login button
            CustomButton(
                buttonText: 'login',
                onPressed: () async {

                  signInWithEmailAndPassword();

                }
            ),

            const SizedBox(height: 10,),
            // sign up text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'don\'t have an account ?' ,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),

                GestureDetector(
                  onTap: ()
                  {
                    Navigator.pushNamed(context, SignUpScreen.id);
                    emailController.clear();
                    passwordController.clear();

                  },
                  child: const Text(
                    '  SignUp' ,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40,),
          ],
        ),
      ),
    ),
  );

  // function called to sign in with email and password
  void signInWithEmailAndPassword() async{

    LoginScreen.currentEmail = email;
    // check the validate of text form field
    if(keyForm.currentState!.validate()){

      // enable the modal progress
      loadModalProgressAndUpdateUi(enabled: true);

      try {

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );


        // to clear the data in text form field after log in
        emailController.clear();
        passwordController.clear();

        displaySnackBarMessage(
            context, 'login success');

        Navigator.pushReplacementNamed(context, ConversionScreen.id);


      } on FirebaseAuthException catch (e) {


        if (e.code == 'invalid-email') {
           displaySnackBarMessage(context, 'invalid email format');
        }
        else if (e.code == 'user-not-found') {
          displaySnackBarMessage(
              context, 'user not found');
        } else if (e.code == 'wrong-password') {
          displaySnackBarMessage(
              context, 'Wrong password');
        }
      }
      catch(e){

        displaySnackBarMessage(
            context, 'there is error, please try again later');
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


