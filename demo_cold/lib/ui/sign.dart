import 'dart:typed_data';

import 'package:demo_cold/sdk/sdk_wrapper.dart';
import 'package:demo_cold/shared/const.dart';
import 'package:demo_cold/shared/req_sign_content.dart';
import 'package:demo_cold/shared/widgets/split_line_text.dart';
import 'package:flutter/material.dart';

import 'sign_result.dart';

class SignPage extends StatefulWidget {
  final ReqSignContent content;
  final String privateKey;
  final String addr;

  const SignPage({Key key, this.content, this.privateKey, this.addr}) : super(key: key);

  @override
  _SignPageState createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('签名')),
      body: ListView(
        children: <Widget>[
          Center(child: Text(widget.content.title(), style: TextStyle(fontSize: 22))),
          SplitLineText(widget.content.info()),
          SizedBox(height: 48),
          Center(
            child: RaisedButton(
              child: Text('使用私钥签名'),
              onPressed: () async {
                String signedData = await signContentUsingPrivateKey(widget.content, widget.privateKey, widget.addr);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SignResult(signedData: signedData)));
              },
            ),
          )
        ],
      ),
    );
  }
}

Future<String> signContentUsingPrivateKey(ReqSignContent content, String privateKey, String addr) async {
  if (content is ReqSignContentCreateMultisigContract) {
    var addrs = content.addrs;
    addrs.sort();
    Uint8List data = await SdkWrapper.packedDeploySimpleMultiSig(content.sigRequired, addrs, CHAIN_ID);
    return SdkWrapper.newETHTransactionForContractCreationAndSign(
        content.nonce, content.gasLimit, content.gasPrice, data, privateKey);
  } else if (content is ReqSignContentETHTransfer) {
    double amountInWei = content.amount * ETH18;
    return SdkWrapper.newTransactionAndSign(
        content.nonce, content.gasLimit, content.gasPrice, content.toAddress, privateKey, amountInWei, content.data);
  } else if (content is ReqSignContentMultisigExecute) {
    String res = await SdkWrapper.signMultisigExecute(content, privateKey, CHAIN_ID);
    return addr + ',' + res;
  } else {
    throw '尚未实现';
  }
}
