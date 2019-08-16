import 'package:demo_cold/shared/const.dart';
import 'package:demo_cold/shared/widgets/paged_qr_image.dart';
import 'package:demo_cold/shared/widgets/snack_info_copied.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignResult extends StatefulWidget {
  final String signedData;

  SignResult({Key key, this.signedData}) : super(key: key);

  @override
  _SignResultState createState() => _SignResultState();
}

class _SignResultState extends State<SignResult> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('签名结果')),
      body: ListView(
        children: <Widget>[
          Text('签名结果(length:${widget.signedData.length})'),
          Text('Hexed:${widget.signedData}', softWrap: false),
          PagedQrImage(data: PATH_SIGNED + widget.signedData),
          SizedBox(height: 16),
          RaisedButton(
            child: Text('复制签名结果'),
            onPressed: () {
              String copy = PATH_SIGNED + widget.signedData;
              Clipboard.setData(ClipboardData(text: copy));
              _scaffoldKey.currentState.showSnackBar(SnackBar(content: SnackInfoCopied(copy)));
            },
          ),
        ],
      ),
    );
  }
}
