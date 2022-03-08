import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:translatr_backend/models/appuser.dart';
import 'package:translatr_backend/models/set.dart';
import 'package:translatr_backend/resources/database_tings.dart';
import 'package:translatr_backend/ui/reusable/mybutton.dart';
import 'package:translatr_backend/ui/set_page.dart';

import '../utils/utils.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _buttonEnabled = true;

  void createSet() async {
    // disable button
    setState(() {
      _buttonEnabled = false;
    });
    Set s = await DatabaseTings().createAndUploadSet(
      title: "",
      description: "",
      userid: widget.user.userid,
      username: widget.user.username,
    );
    if (s.setid != "") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SetPage(set: s)));
      showSnackBar(context, "success");
    } else {
      showSnackBar(context, "Some error occured. Please try again.");
    }
    // enable button
    setState(() {
      _buttonEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            Text("Welcome, " + widget.user.firstName + "!"),
            MyButton(
              text: "Create Set",
              onPress: createSet,
              isEnabled: _buttonEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
