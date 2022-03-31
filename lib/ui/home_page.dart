import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:translatr_backend/models/appuser.dart';
import 'package:translatr_backend/models/set.dart';
import 'package:translatr_backend/resources/database_tings.dart';
import 'package:translatr_backend/ui/reusable/mybutton.dart';
import 'package:translatr_backend/ui/set_page.dart';

import '../resources/auth_tings.dart';
import '../utils/utils.dart';

class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _buttonEnabled = true;
  List<Set> _usersets = [];

  void init() async {
    var sets =
        await DatabaseTings().downloadUserSets(userid: widget.user.userid);
    setState(() {
      _usersets = sets;
    });
  }

  void logOut() async {
    await AuthTings().signOut();
    Navigator.pop(context);
  } // TODO: bugs logging out sometimes

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> newSet() async {
    Set s = await DatabaseTings().createAndUploadSet(
      title: "Untitled",
      description: "",
      userid: AuthTings.currentUser.userid,
      username: AuthTings.currentUser.username,
    );
    setState(() {
      _usersets.add(s);
    });
    await navigateToSetView(s);
  } // TODO: make this work

  Future<void> navigateToSetView(Set s) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SetPage(set: s)));
    init();
  }

  void deleteSet(int index) async {
    String res = "Some error occured";
    res = await DatabaseTings().deleteSet(set: _usersets[index]);
    init();
    showSnackBar(context, res); // TODO: snack bar not showing
  }

  showDeleteSetAlertDialog(BuildContext context, int index, String setTitle) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () {
        deleteSet(index);
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "Are you sure you want to delete '$setTitle'? \nThis action is irreversible."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              "Welcome, " + widget.user.firstName + "!",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 50),
            MyButton(text: "Log Out", onPress: logOut),
            const SizedBox(height: 25),
            MyButton(
              text: "Create Set",
              onPress: newSet,
              isEnabled: _buttonEnabled,
            ),
            const SizedBox(height: 50),
            Expanded(
              child: (_usersets.isEmpty)
                  ? const Text(
                      "No sets added",
                      textAlign: TextAlign.center,
                    )
                  : ListView.builder(
                      itemCount: _usersets.length,
                      itemBuilder: (context, index) {
                        return SetListItem(
                          deleteFunction: () => showDeleteSetAlertDialog(
                            context,
                            index,
                            _usersets[index].title,
                          ),
                          navigateFunction: () =>
                              navigateToSetView(_usersets[index]),
                          setTitle: _usersets[index].title,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SetListItem extends StatelessWidget {
  final deleteFunction;
  final navigateFunction;
  final String setTitle;

  const SetListItem({
    Key? key,
    required this.deleteFunction,
    required this.navigateFunction,
    required this.setTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MyButton(
          text: "X",
          onPress: deleteFunction,
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: navigateFunction,
          child: Text(setTitle),
        ),
      ],
    );
  }
}
