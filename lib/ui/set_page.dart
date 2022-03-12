import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:translatr_backend/models/set.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
import 'package:translatr_backend/resources/database_tings.dart';
import 'package:translatr_backend/ui/reusable/mybutton.dart';
import 'package:translatr_backend/ui/reusable/mytextfield.dart';

import '../utils/utils.dart';

class SetPage extends StatefulWidget {
  final Set set;

  const SetPage({Key? key, required this.set}) : super(key: key);

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _buttonEnabled = true;
  final TextEditingController _newTermFrontController = TextEditingController();
  final TextEditingController _newTermBackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.set.title;
    _descriptionController.text = widget.set.description;
  }

  void goBack() {
    Navigator.pop(context);
  }

  void saveSet() async {
    if (_titleController.text == "") {
      showSnackBar(context, "Set Title cannot be empty");
      return;
    }

    // disable button
    setState(() {
      _buttonEnabled = false;
    });

    // create new set if setid is empty
    if (widget.set.setid.isEmpty) {
      await DatabaseTings().createAndUploadSet(
        title: _titleController.text,
        description: _descriptionController.text,
        userid: AuthTings.currentUser.userid,
        username: AuthTings.currentUser.username,
      );
    }
    // update fields otherwise
    else {
      String res = await DatabaseTings().updateSet(
        setid: widget.set.setid,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      showSnackBar(context, res);
    }

    // enable button
    setState(() {
      _buttonEnabled = true;
    });

    goBack();
  }

  void addTerm() async {
    String res = await DatabaseTings().addTermToSet(
      front: _newTermFrontController.text,
      back: _newTermBackController.text,
      s: widget.set,
    );
    setState(() {
      widget.set.terms[_newTermFrontController.text] =
          _newTermBackController.text;
    });
    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            MyButton(text: "Back", onPress: goBack),
            MyTextField(
              textController: _titleController,
              labelText: "Set Title",
            ),
            MyTextField(
              textController: _descriptionController,
              labelText: "Set Description",
            ),
            MyButton(
              onPress: saveSet,
              text: "Save Set",
              isEnabled: _buttonEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
