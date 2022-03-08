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

  void login() async {
    String res = await AuthTings().authenticateUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (res == "success") {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePage(user: AuthTings.currentUser)));
    }
    showSnackBar(context, res);
  }

  void navigateToSignUp() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              labelText: "email",
              textController: _emailController,
            ),
            MyTextField(
              labelText: "password",
              textController: _passwordController,
              isPassword: true,
            ),
            MyButton(
              text: "Log In",
              onPress: login,
            ),
            Container(height: 50),
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
