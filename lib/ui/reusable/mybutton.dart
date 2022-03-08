import 'package:flutter/material.dart';

// TODO: implement loading animation. Refer to instagram clone for reference

class MyButton extends StatelessWidget {
  // void callback function telling button what to do when pressed
  final VoidCallback onPress;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double width;
  final bool isEnabled;

  const MyButton({
    Key? key,
    required this.onPress,
    this.text = "",
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.height = 50,
    this.width = 150,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: height,
        width: width,
        color: isEnabled ? backgroundColor : Colors.blueGrey,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
