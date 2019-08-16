import 'package:demo_cold/models/addr.dart';
import 'package:demo_cold/shared/const.dart';
import 'package:demo_cold/shared/req_sign_content.dart';
import 'package:demo_cold/shared/widgets/action_import_data.dart';
import 'package:demo_cold/shared/widgets/copy_qrcode_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qr_flutter/qr_flutter.dart';

import 'key_list.dart';
import 'sign.dart';

class KeyDetailPage extends StatefulWidget {
  static final String routeName = "/key";

  final Addr addr;

  const KeyDetailPage({Key key, @required this.addr}) : super(key: key);

  @override
  _KeyDetailPageState createState() => _KeyDetailPageState();
}

class _KeyDetailPageState extends State<KeyDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void actionShowQRCode(String content) {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (ctx) => Scaffold(
        body: ListView(
          children: <Widget>[
            Text(content),
            QrImage(data: content, size: 250.0),
            IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(ctx))
          ],
        ),
      ),
    );
  }

  void actionDelKey(BuildContext context) {
    var dialogBuilder = (BuildContext ctx) => AlertDialog(
          title: Text('确定删除？'),
          content: Text('私钥一旦删除将不可找回，同时也会删除地址，公钥'),
          actions: <Widget>[
            FlatButton(
                child: Text('删除'),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  List<String> l = prefs.getStringList(storeKey);
                  l.removeWhere((encoded) => encoded.contains(widget.addr.privateKey));
                  prefs.setStringList(storeKey, l);
                  Navigator.pop(ctx);
                  Navigator.pop(_scaffoldKey.currentContext);
                }),
            FlatButton(child: Text('取消'), onPressed: () => Navigator.pop(ctx)),
          ],
        );
    showDialog(context: context, builder: dialogBuilder);
  }

  void parseReqSignDataThenShowSign(String reqSignData) {
    try {
      ReqSignContent content = parseReqSignContent(reqSignData);
      Navigator.of(_scaffoldKey.currentContext).push(MaterialPageRoute(
          builder: (_) => SignPage(
                content: content,
                privateKey: widget.addr.privateKey,
                addr: widget.addr.address,
              )));
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('无法解析待签名数据,$reqSignData, $err')));
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("地址详情")),
      body: ListView(
        children: <Widget>[
          Center(child: Text('⚠️生成的私钥/地址仅用于测试演示', style: TextStyle(fontSize: 20, color: Colors.redAccent))),
          Row(children: <Widget>[
            Expanded(child: Text('地址：${widget.addr.address}')),
            CopyOrShowQRCode(text: PATH_ADDR + widget.addr.address),
          ]),
          Row(children: <Widget>[
            Expanded(child: Text('公钥：${widget.addr.publicKey}')),
            CopyOrShowQRCode(text: PATH_PUBKEY + widget.addr.publicKey),
          ]),
          Row(children: <Widget>[
            Expanded(child: Text('私钥：${widget.addr.privateKey}')),
            CopyOrShowQRCode(text: PATH_PRIVATEKEY + widget.addr.privateKey),
          ]),
          SizedBox(height: 36),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
            RaisedButton(
                child: Text('扫码签名'),
                onPressed: () async {
                  String futureString = await readImportData(context, source: FromCamera);
                  parseReqSignDataThenShowSign(futureString);
                }),
            RaisedButton(
                child: Text('从剪切板读取待签名数据'),
                onPressed: () async {
                  var data = (await Clipboard.getData(null)).text;
                  parseReqSignDataThenShowSign(data);
                }),
          ]),
          SizedBox(height: 36),
          Center(
            child: RaisedButton(
              child: Text('删除私钥', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => actionDelKey(context),
            ),
          ),
        ],
      ),
    );
  }
}
