import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'snack_info_copied.dart';

class CopyBtn extends StatelessWidget {
  final String content;

  const CopyBtn({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '复制',
      icon: Icon(Icons.content_copy),
      onPressed: () {
        Clipboard.setData(ClipboardData(text: content));
        Scaffold.of(context).showSnackBar(SnackBar(content: SnackInfoCopied(content)));
        print('copied:\n$content\n');
      },
    );
  }
}
