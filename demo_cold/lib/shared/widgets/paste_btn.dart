import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasteBtn extends StatelessWidget {
  final Function(String) callback;

  const PasteBtn({Key key, @required this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () async {
        String ret = (await Clipboard.getData('text/plain')).text;
        callback(ret);
      },
    );
  }
}
