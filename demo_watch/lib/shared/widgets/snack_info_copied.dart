import 'package:flutter/material.dart';

class SnackInfoCopied extends StatelessWidget {
  final String text;

  SnackInfoCopied(this.text);
  @override
  Widget build(BuildContext context) {
    String txt = text;
    if (txt.length > 200) {
      txt = text.substring(0, 200) + "...";
    }
    return Row(
      children: <Widget>[
        Text('copied:', style: TextStyle(color: Colors.lightBlue)),
        Expanded(child: Text(txt)),
      ],
    );
  }
}
