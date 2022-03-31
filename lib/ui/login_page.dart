import 'dart:html';

import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:translatr_backend/models/appuser.dart';
import 'package:translatr_backend/ui/home_page.dart';
import 'package:translatr_backend/ui/reusable/mybutton.dart';
import 'package:translatr_backend/ui/reusable/mytextfield.dart';
import 'package:translatr_backend/ui/signup_page.dart';

import '../resources/auth_tings.dart';
import '../utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _buttonEnabled = true;

  // log in user if already authenticated
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      if (AuthTings.currentUser.userid.isEmpty) {
        AuthTings().loadUserInfo();
      }
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage(user: AuthTings.currentUser)));
    }
  }

  void login() async {
    // disable button
    setState(() {
      _buttonEnabled = false;
    });
    String res = await AuthTings().authenticateUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res == "success") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => HomePage(user: AuthTings.currentUser)));
    }
    // enable button
    showSnackBar(context, res);
    setState(() {
      _buttonEnabled = true;
    });
  }

  void navigateToSignUp() {
    setState(() {
      _buttonEnabled = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpPage(
          defaultEmail: _emailController.text,
          defaultPassword: _passwordController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Cardslate",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 25),
            MyTextField(
              labelText: "email",
              textController: _emailController,
            ),
            MyTextField(
              labelText: "password",
              textController: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 25),
            MyButton(
              text: "Log In",
              onPress: login,
              isEnabled: _buttonEnabled,
            ),
            const SizedBox(height: 25),
            MyButton(
              text: "Don't have an account? Sign Up",
              onPress: navigateToSignUp,
            ),
          ],
        ),
      ),
    );
  }
}
