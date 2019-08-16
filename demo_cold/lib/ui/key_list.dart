import 'dart:async';

import 'package:demo_cold/models/addr.dart';
import 'package:demo_cold/sdk/sdk_wrapper.dart';
import 'package:demo_cold/shared/const.dart';
import 'package:demo_cold/shared/utl.dart';
import 'package:demo_cold/shared/widgets/action_import_data.dart';
import 'package:demo_cold/ui/key_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String storeKey = "encoded_keys";

class KeyListPage extends StatefulWidget {
  static final String routeName = "/addrlist";

  @override
  _KeyListPageState createState() => _KeyListPageState();
}

class _KeyListPageState extends State<KeyListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<Addr> keys = [];

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(loadKey);
  }

  void loadKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(storeKey) ?? [];
    if (l.length == keys.length) {
      return;
    }
    setState(() {
      keys = l.map((encoded) => Addr.decode(encoded)).toList(growable: false);
    });
  }

  Future<void> addKey(Addr addr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> l = prefs.getStringList(storeKey) ?? [];
    l.add(addr.encode());
    prefs.setStringList(storeKey, l);
    loadKey();
  }

  void actionImportPrivateKey() async {
    var data = await readImportData(_scaffoldKey.currentContext);
    if (data == null) {
      return;
    }
    data = trimLeftUrlSchema(data);
    data = utlTrimLeft(data, PATH_PRIVATEKEY);
    var ret = await SdkWrapper.genKey(data);
    Addr addr = Addr()
      ..privateKey = ret[0]
      ..publicKey = ret[1]
      ..address = ret[2];
    await addKey(addr);
  }

  void actionGenerateKeyAndSave() async {
    var ret = await SdkWrapper.genKey(null);
    Addr addr = Addr()
      ..privateKey = ret[0]
      ..publicKey = ret[1]
      ..address = ret[2];
    await addKey(addr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('地址列表')),
      body: Scrollbar(
        child: ListView(
          children: <Widget>[
            Center(child: Text('⚠️生成的私钥/地址仅用于测试演示', style: TextStyle(fontSize: 20, color: Colors.redAccent))),
            SizedBox(height: 16),
            for (Addr ad in keys)
              ListTile(
                title: Text(ad.address),
                trailing: Icon(Icons.arrow_forward),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => KeyDetailPage(addr: ad)));
                  loadKey();
                },
              ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(child: Text("生成私钥"), onPressed: actionGenerateKeyAndSave),
                RaisedButton(child: Text("导入私钥"), onPressed: actionImportPrivateKey)
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
