import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:translatr_backend/models/appuser.dart';
import 'package:translatr_backend/models/set.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
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
  List<Set> _usersets = [];

  void init() async {
    var sets =
        await DatabaseTings().downloadUserSets(userid: widget.user.userid);
    setState(() {
      _usersets = sets;
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  // TODO: newly created sets don't show up when navigating back from set page
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
      navigateToSetView(
          s); // TODO: Pass in set.none at first. Create new set in set_page only if title field is non-null
      showSnackBar(context, "success");
    } else {
      showSnackBar(context, "Some error occured. Please try again.");
    }
    // enable button
    setState(() {
      _buttonEnabled = true;
    });
  }

  void navigateToSetView(Set s) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => SetPage(set: s)));
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            MyButton(text: "Back", onPress: () => Navigator.pop(context)),
            Text("Welcome, " + widget.user.firstName + "!"),
            MyButton(
              text: "Create Set",
              onPress: createSet,
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
                        return GestureDetector(
                          onTap: () => navigateToSetView(_usersets[index]),
                          child: Text(_usersets[index].title),
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
