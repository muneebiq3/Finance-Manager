import 'package:flutter/material.dart';

import '../themes/images.dart';

class ManualWidgets extends StatefulWidget {
  const ManualWidgets({super.key});

  @override
  State<ManualWidgets> createState() => _ManualWidgetsState();

  static Widget title() {
    return Image.asset(
      Images.wallet, 
      height: 100, 
      width: 100
    );
  }

  static Widget message(String text) {

    return Text(

      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      
    );
  }

  static Widget entryField(String title, TextEditingController controller, String placeholder, bool hide) {

    return TextField(

      controller: controller,
      obscureText: hide,
      cursorColor: Colors.white,

      decoration: InputDecoration(

        labelText: title,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        
      ),

      style: const TextStyle(color: Colors.white),
    );

  }

  static Widget passwordField ({

    required String title,
    required TextEditingController controller,
    required String placeholder,
    required bool hidePassword,
    required VoidCallback onToggleVisibility,

  }) {

    return TextField(

      controller: controller,
      obscureText: hidePassword,
      cursorColor: Colors.white,

      decoration: InputDecoration (

        labelText: title,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: placeholder,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),

        suffixIcon: IconButton(

          onPressed: onToggleVisibility,
          icon: Icon(
            hidePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),

        ),

      ),

      style: const TextStyle(color: Colors.white),

    );

  }

  static Widget labelButton({

    required String text, 
    required VoidCallback onPressed

  }) {

     return TextButton(

      onPressed: onPressed,

      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  static Widget loginRegisterButton(String text, VoidCallback onPressed) {

    return ElevatedButton(

      onPressed: onPressed,

      style: ElevatedButton.styleFrom(

        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),

      ),
      
      child: Text(text),
    );
  }

  static Widget associatedLoginButton({

    required VoidCallback onTap,
    required String imageAsset

  }) {

    return InkWell(
      
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),

      child: Container(

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(

          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],

        ),

        child: Image.asset(

          imageAsset,
          height: 30,
          width: 30,

        ),

      ),

    );

  }

  static Widget sendButton ({

    required String text,
    required double width,
    required bool isLoading,
    required VoidCallback onPressed,

  }) {

    return SizedBox(

      width: width,
      child: ElevatedButton(

        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(

          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF90B3E9), // Theme color for button text
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),

        ),

        child: Text(text),
      ),
    );
  }

}

class _ManualWidgetsState extends State<ManualWidgets> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}