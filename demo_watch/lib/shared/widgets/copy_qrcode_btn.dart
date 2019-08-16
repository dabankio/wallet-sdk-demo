import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../assets.dart';

class CopyOrShowQRCode extends StatelessWidget {
  final String text;

  const CopyOrShowQRCode({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Row(
        children: [
          IconButton(
            tooltip: '复制',
            icon: Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Row(
                  children: <Widget>[
                    Text('copied:', style: TextStyle(color: Colors.lightBlue)),
                    Expanded(child: Text(text)),
                  ],
                ),
              ));
            },
          ),
          IconButton(
            icon: ImageIcon(AssetImage(ASSETS_QR_CODE)),
            tooltip: '显示二维码',
            onPressed: () => actionShowQRCode(text, context),
          ),
        ],
      ),
    );
  }

  void actionShowQRCode(String content, BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (ctx) => Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 24),
                Text(content),
                QrImage(data: content, size: 360.0),
                SizedBox(height: 36),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
