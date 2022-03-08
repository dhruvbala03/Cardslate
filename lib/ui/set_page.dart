import 'package:flutter/material.dart';
import 'package:translatr_backend/models/set.dart';
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

  void saveSet() async {
    String res = await DatabaseTings().updateSet(
      setid: widget.set.setid,
      title: _titleController.text,
      description: _descriptionController.text,
    );
    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            MyTextField(
              textController: _titleController,
              labelText: "Set Name",
            ),
            MyTextField(
              textController: _descriptionController,
              labelText: "Set Description",
            ),
            MyButton(
              onPress: saveSet,
              text: "Save Set",
            )
          ],
        ),
      ),
    );
  }
}
