// 创建多签合约页面
import 'package:demo_watch/shared/utl.dart';
import 'package:demo_watch/shared/widgets/paste_or_scan.dart';
import 'package:flutter/material.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/shared/const.dart';
import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:oktoast/oktoast.dart';

import 'request_sign.dart';

class CreqteMultisigContract extends StatefulWidget {
  final String addr0;

  const CreqteMultisigContract({Key key, this.addr0}) : super(key: key);

  @override
  _CreqteMultisigContractState createState() => _CreqteMultisigContractState();
}

class _CreqteMultisigContractState extends State<CreqteMultisigContract> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController addr0Ctrl = TextEditingController();
  final TextEditingController addr1Ctrl = TextEditingController();

  int sigNumber = 1;
  String addr1;

  String message;

  @override
  void initState() {
    super.initState();
    addr0Ctrl.text = widget.addr0;
  }

  void setAnotherAddr(String addr) {
    print(addr);
    if (addr?.isEmpty ?? true) {
      showToast('空地址', duration: Duration(seconds: 3));
      return;
    }
    trimLeftUrlSchema(addr);
    setState(() {
      addr1 = utlTrimLeft(addr, PATH_ADDR);
      addr1Ctrl.text = addr1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('创建简单多签合约')),
      body: ListView(children: <Widget>[
        if (message != null) Column(children: <Widget>[LinearProgressIndicator(), Text(message)]),
        Text('签名人数', style: TextStyle(fontSize: 24)),
        Row(children: <Widget>[
          Text('1'),
          Radio(
            value: 1,
            groupValue: sigNumber,
            onChanged: (i) {
              setState(() {
                sigNumber = 1;
              });
            },
          ),
          Text('2'),
          Radio(
            value: 2,
            groupValue: sigNumber,
            onChanged: (i) {
              setState(() {
                print(i);
                sigNumber = 2;
              });
            },
          ),
        ]),
        TextField(
          controller: addr0Ctrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: '地址1',
          ),
        ),
        Row(children: <Widget>[
          Expanded(
            child: TextField(
              controller: addr1Ctrl,
              decoration: InputDecoration(
                labelText: '地址2',
              ),
              onChanged: (v) {
                setState(() {
                  addr1 = v;
                });
              },
            ),
          ),
          PasteOrScan(callback: (v) => setAnotherAddr(v)),
        ]),
        SizedBox(height: 16),
        RaisedButton(
          child: Text('生成创建合约交易待签名数据'),
          onPressed: () async {
            if (addr1 == null || addr1.isEmpty) {
              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('地址2为空')));
              return;
            }
            setState(() {
              message = '读取nonce,gasPrice,gasLimit';
            });
            var nonceGaspriceGaslimit = await EthRpc.getNonceGaspriceGaslimit(widget.addr0);
            var nonce = nonceGaspriceGaslimit[0];
            var gasPrice = nonceGaspriceGaslimit[1];
            var gasLimit = nonceGaspriceGaslimit[2];
            if (!mounted) {
              return;
            }
            setState(() {
              message = null;
            });

            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RequestSignPage(
                    content: ReqSignContentCreateMultisigContract()
                      ..nonce = nonce
                      ..gasPrice = gasPrice
                      ..gasLimit = gasLimit
                      ..sigRequired = sigNumber
                      ..addrs = [widget.addr0, addr1])));
          },
        )
      ]),
    );
  }
}
