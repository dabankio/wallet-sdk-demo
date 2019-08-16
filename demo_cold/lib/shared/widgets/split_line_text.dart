import 'package:flutter/material.dart';

/// 多行文本
class SplitLineText extends StatelessWidget {
  final String text;

  SplitLineText(this.text);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: text.split('\n').map((txt) => Text(txt)).toList(growable: false),
    );
  }
}
