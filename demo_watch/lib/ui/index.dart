import 'package:demo_watch/repo/repo.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/sdk/sdk_wrapper.dart';
import 'package:demo_watch/shared/widgets/paste_btn.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import 'addr_list.dart';

class IndexPage extends StatefulWidget {
  static const String routeName = "/";
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final TextEditingController rpcCtl = TextEditingController();

  String sdkBuildTime = '';

  @override
  void initState() {
    super.initState();
    Repo.getRPCUrl().then((url) {
      rpcCtl.text = url;
      EthRpc.rpcUrl = url;
    });
    SdkWrapper.buildTime().then((v) {
      setState(() {
        sdkBuildTime = v ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(children: <Widget>[
            Expanded(
              child: TextField(
                decoration: InputDecoration(labelText: 'rpcUrl'),
                controller: rpcCtl,
              ),
            ),
            PasteBtn(callback: (v) => rpcCtl.text = v),
          ]),
          SizedBox(height: 12),
          RaisedButton(
            child: Text('设置rpcurl'),
            onPressed: () async {
              await Repo.setRPCUrl(rpcCtl.text);
              EthRpc.rpcUrl = rpcCtl.text;
              showToast('done');
            },
          ),
          SizedBox(height: 24),
          RaisedButton(
            child: Text('进入地址列表页'),
            onPressed: () => Navigator.of(context).pushReplacementNamed(AddrList.routeName),
          ),
          Text('SDK build at:' + sdkBuildTime ?? ''),
        ],
      ),
    );
  }
}
