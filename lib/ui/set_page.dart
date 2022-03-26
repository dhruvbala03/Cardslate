import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:translatr_backend/models/set.dart';
import 'package:translatr_backend/resources/auth_tings.dart';
import 'package:translatr_backend/resources/database_tings.dart';
import 'package:translatr_backend/ui/reusable/mybutton.dart';
import 'package:translatr_backend/ui/reusable/mytextfield.dart';
import 'package:translatr_backend/utils/translator.dart';

import '../models/term.dart';
import '../utils/utils.dart';

class SetPage extends StatefulWidget {
  final Set set;

  const SetPage({
    Key? key,
    required this.set,
  }) : super(key: key);

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _buttonEnabled = true;

  List<Term> terms = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.set.title;
    _descriptionController.text = widget.set.description;
    init();
  }

  void init() async {
    var t = await DatabaseTings().extractTermsFromSet(set: widget.set);
    setState(() {
      terms = t;
    });
  }

  Future<void> loadTerms() async {
    terms = await DatabaseTings().extractTermsFromSet(set: widget.set);
    _descriptionController.text = "error initializing";
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

    // // create new set if setid is empty
    // if (isNewSet) {
    //   await DatabaseTings().createAndUploadSet(
    //     title: _titleController.text,
    //     description: _descriptionController.text,
    //     userid: AuthTings.currentUser.userid,
    //     username: AuthTings.currentUser.username,
    //   );
    //   isNewSet = false;
    // }

    // update fields otherwise
    String res = await DatabaseTings().updateSet(
      setid: widget.set.setid,
      title: _titleController.text,
      description: _descriptionController.text,
    );
    showSnackBar(context, res);

    // enable button
    setState(() {
      _buttonEnabled = true;
    });

    // goBack();
  }

  Future<void> addTerm() async {
    Term term = await DatabaseTings().newTermToSet(
      front: "Untitled",
      back: "",
      set: widget.set,
    );
    if (term.termid.isNotEmpty) {
      setState(() {
        terms.add(term);
      });
    }
    // TODO: what happens if termId is empty?
  }

  void deleteTerm({required Term term}) async {
    String res = await DatabaseTings().deleteTerm(
      term: term,
    ); // display snackbar something with res?
    setState(() {
      terms.remove(term);
    });
  }

  void updateTerm({
    required Term term,
    required String front,
    required String back,
  }) async {
    String res = await DatabaseTings().editTerm(
      term: term,
      front: front,
      back: back,
    ); // display snackbar something with res?
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
                      itemCount: terms.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TermView(
                          term: terms[index],
                          deleteFunction: () => deleteTerm(term: terms[index]),
                          editFunction: ({
                            required String front,
                            required String back,
                          }) =>
                              updateTerm(
                            term: terms[index],
                            front: front,
                            back: back,
                          ),
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
  final Term term;
  final deleteFunction;
  final editFunction;

  const TermView(
      {Key? key,
      required this.term,
      required this.deleteFunction,
      required this.editFunction})
      : super(key: key);

  @override
  State<TermView> createState() => _TermViewState();
}

class _TermViewState extends State<TermView> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _frontController.text = widget.term.front;
    _backController.text = widget.term.back;
  }

  void translateAndUpdateTerm() async {
    String language = "english";
    _backController.text = await Translator.translate(
      text: _frontController.text,
      language: language,
    );
    widget.editFunction(
      front: _frontController.text,
      back: _backController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.deleteFunction,
          child: Text('X'),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: MyTextField(
            textController: _frontController,
            labelText: 'front',
            onEdit: translateAndUpdateTerm,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: MyTextField(
            isEnabled: false,
            textController: _backController,
            labelText: 'back',
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: translateAndUpdateTerm,
          child: Text('save'),
        ), // TODO: make this automatic so that the user does not have to click a button to save
      ],
    );
  }
}
