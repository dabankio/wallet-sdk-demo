import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assets.dart';
import 'action_import_data.dart';

class PasteOrScan extends StatelessWidget {
  final Function(String) callback;

  const PasteOrScan({Key key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () async {
              String ret = (await Clipboard.getData('text/plain')).text;
              callback(ret);
            },
          ),
          IconButton(
            icon: ImageIcon(AssetImage(ASSETS_SCAN_QR)),
            onPressed: () async {
              String ret = await scanQRCode();
              callback(ret);
            },
          )
        ],
      ),
    );
  }
}
