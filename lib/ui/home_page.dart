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
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void navigateToSetView(Set s) async {
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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            MyButton(text: "Log Out", onPress: logOut),
            Text("Welcome, " + widget.user.firstName + "!"),
            MyButton(
              text: "Create Set",
              onPress: () => navigateToSetView(Set.none()),
              isEnabled: _buttonEnabled,
            ),
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
                          deleteFunction: () => deleteSet(index),
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
        GestureDetector(
          onTap: navigateFunction,
          child: Text(setTitle),
        ),
      ],
    );
  }
}
