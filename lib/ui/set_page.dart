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

// TODO: FIX WEIRD EXCEPTION WHEN CREATING NEW SET
class _SetPageState extends State<SetPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _buttonEnabled = true;

  List<TextEditingController> _termFrontEditingControllers = [];
  List<String> terms = [];
  // TODO: make this a list of term-ids. there will be a collection of terms, each in their own document with the name being their term ID; these documents will have front and back fields

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.set.title;
    _descriptionController.text = widget.set.description;
  }

  void updateTermsList() {
    List<String> temp = [];
    for (var controller in _termFrontEditingControllers) {
      temp.add(controller.text);
    } // TODO: inefficient? and what about when we translate stuff?
    terms = temp;
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

    // update terms list
    updateTermsList();

    // create new set if setid is empty
    if (widget.set.setid.isEmpty) {
      // TODO: what if set is new??
      await DatabaseTings().createAndUploadSet(
        title: _titleController.text,
        description: _descriptionController.text,
        userid: AuthTings.currentUser.userid,
        username: AuthTings.currentUser.username,
        terms: terms,
      );
    }
    // update fields otherwise
    else {
      String res = await DatabaseTings().updateSet(
        setid: widget.set.setid,
        title: _titleController.text,
        description: _descriptionController.text,
        terms: terms,
      );
      showSnackBar(context, res);
    }

    // enable button
    setState(() {
      _buttonEnabled = true;
    });

    goBack();
  }

  void addTerm() {
    // TODO: make auto-save
    String front = "Untitled" + terms.length.toString();
    terms.add(front);
    setState(() {
      _termFrontEditingControllers.add(TextEditingController(text: front));
    });
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
            const SizedBox(height: 50),
            Expanded(
              child: (terms.isEmpty)
                  ? const Text(
                      "No terms added",
                      textAlign: TextAlign.center,
                    )
                  : ListView.builder(
                      itemCount: _termFrontEditingControllers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TermView(
                          termFrontController:
                              _termFrontEditingControllers[index],
                        );
                      },
                    ),
            ),
            MyButton(
              text: "+",
              onPress: addTerm,
            ),
          ],
        ),
      ),
    );
  }
}

class TermView extends StatefulWidget {
  final TextEditingController termFrontController;

  const TermView({Key? key, required this.termFrontController})
      : super(key: key);

  @override
  State<TermView> createState() => _TermViewState();
}

class _TermViewState extends State<TermView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
            textController: widget.termFrontController,
            labelText: 'front',
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: MyTextField(
            textController: widget.termFrontController,
            labelText: 'back',
          ),
        ), // DISPLAY TRANSLATED TEXT IN REAL TIME
      ],
    );
  }
}
