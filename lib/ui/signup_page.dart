import 'package:flutter/material.dart';
import 'package:translatr_backend/ui/reusable/mytextfield.dart';

import '../resources/auth_tings.dart';
import '../utils/utils.dart';
import 'home_page.dart';
import 'reusable/mybutton.dart';

class SignUpPage extends StatefulWidget {
  final String defaultEmail;
  final String defaultPassword;

  const SignUpPage(
      {Key? key, required this.defaultEmail, required this.defaultPassword})
      : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _buttonEnabled = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.defaultEmail;
    _passwordController.text = widget.defaultPassword;
  }

  void signup() async {
    // disable button
    setState(() {
      _buttonEnabled = false;
    });

    // register user
    String res = await AuthTings().registerUser(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    // authenticate user
    if (res == "success") {
      res = await AuthTings().authenticateUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // navigate to homepage if successful login
      if (res == "success") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(user: AuthTings.currentUser)),
            (route) => false);
      }
      // enable button
      setState(() {
        _buttonEnabled = true;
      });
    }

    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButton(text: "Back", onPress: () => Navigator.pop(context)),
            MyTextField(
              labelText: "first name",
              textController: _firstNameController,
            ),
            // last name field
            MyTextField(
              labelText: "last name",
              textController: _lastNameController,
            ),
            MyTextField(
              labelText: "username",
              textController: _usernameController,
            ),
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
              text: "Sign Up",
              onPress: signup,
              isEnabled: _buttonEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
