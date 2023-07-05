import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  String? labelText;
  // to store data coming from text field
  Function(String)? onChange;
  // for receive the text input type
  TextInputType? keyboardType;
  // for receive the prefix and suffix icon
  Icon? prefixIcon;
  IconButton? suffixIcon ;
  // check if obscure or not
  bool obscure;
  // for clearing the data
  TextEditingController? controller = TextEditingController();

  // constructor
   CustomTextFormField({
     this.labelText,
     this.keyboardType ,
     this.onChange,
     this.prefixIcon,
     this.suffixIcon,
     this.obscure = false,
     this.controller,

   });


  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: controller,

      obscureText: obscure,
      // choosing keyboard type
      keyboardType: keyboardType,
      // to check the validate of the input data is correct
      validator:  (data){
        if(data.toString().isEmpty){
          return '$labelText is required';
        }
      },
      // to store data coming from text field
      onChanged: onChange,

      // design text field
      style: const TextStyle(
        fontSize: 15,
        color: Colors.white,
      ),

      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        //contentPadding: const EdgeInsets.symmetric(vertical: 25 , horizontal: 6),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white ,
          ),
        ) ,

        border: const OutlineInputBorder(),
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),

      ),
    );
  }
}
