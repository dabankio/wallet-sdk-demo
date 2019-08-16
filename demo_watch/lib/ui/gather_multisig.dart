// 收集多签签名页面

import 'dart:typed_data';

import 'package:demo_watch/shared/const.dart';
import 'package:demo_watch/shared/widgets/copy_btn.dart';
import 'package:demo_watch/shared/widgets/paste_or_scan.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/sdk/sdk_wrapper.dart';
import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:demo_watch/shared/widgets/split_line_text.dart';
import 'package:demo_watch/ui/request_sign.dart';

class GatherMultisigSigPage extends StatefulWidget {
  final ReqSignContent content;
  final AddrInfo addr;

  const GatherMultisigSigPage({Key key, this.content, this.addr}) : super(key: key);

  @override
  _GatherMultisigSigPageState createState() => _GatherMultisigSigPageState();
}

class _GatherMultisigSigPageState extends State<GatherMultisigSigPage> {
  // List<String> sigs;
  List<TextEditingController> ctrls;
  String loadingMessage;

  @override
  void initState() {
    super.initState();
    // sigs = List.generate(widget.addr.sigRequired, (_) => null);
    ctrls = List.generate(widget.addr.sigRequired, (_) => TextEditingController());
  }

  void actionBuildData2sign() async {
    List<String> sigs = ctrls.map((c) => c.text).toList();
    if (sigs.any((v) => v == null)) {
      showToast('收集签名数尚未达成', backgroundColor: Colors.redAccent);
      return;
    }

    setState(() {
      loadingMessage = '获取nonce,gasPrice,gasLimit';
    });
    ReqSignContentMultisigExecute exec = widget.content;
    var nonceGaspriceGaslimit = await EthRpc.getNonceGaspriceGaslimit(exec.exectorAddress);
    if (!mounted) {
      return;
    }
    setState(() {
      loadingMessage = null;
    });
    var nonce = nonceGaspriceGaslimit[0];
    var gasPrice = nonceGaspriceGaslimit[1];
    var gasLimit = nonceGaspriceGaslimit[2];
    sigs.sort();

    double amountInWei = exec.amount * ETH18;
    Uint8List packedExecuteData = await SdkWrapper.simpleMultisigPackedExecute(
      toAddress: exec.toAddress,
      amount: amountInWei,
      data: null,
      gasLimit: gasLimit,
      executor: exec.exectorAddress,
      sortedSigs: sigs.map((addrSig) => addrSig.split(',')[1]).toList(growable: false),
    );

    var reqSign = ReqSignContentETHTransfer()
      ..nonce = nonce
      ..toAddress = widget.addr.addr //合约地址
      ..amount = 0
      ..gasLimit = gasLimit
      ..gasPrice = gasPrice
      ..data = packedExecuteData;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RequestSignPage(
              content: reqSign,
              addr: widget.addr,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('收集签名')),
      body: ListView(
        children: <Widget>[
          if (loadingMessage != null) Column(children: <Widget>[LinearProgressIndicator(), Text(loadingMessage)]),
          Text(widget.content.title()),
          SplitLineText(widget.content.info()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('原始数据:'),
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 160),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Text(widget.content.encode()),
                    ),
                  ),
                ),
              ),
              CopyBtn(content: urlWithAppSchema(PATH_REQ_SIGN_CONTENT + widget.content.encode())),
            ],
          ),
          Text('需要的签名数：${widget.addr.sigRequired}'),
          ...List.generate(
            widget.addr.sigRequired,
            (int idx) => Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    maxLines: 3,
                    controller: ctrls[idx],
                    decoration: InputDecoration(labelText: '签名${idx + 1}'),
                  ),
                ),
                PasteOrScan(callback: (v) => ctrls[idx].text = v),
              ],
            ),
          ),
          SizedBox(height: 24),
          RaisedButton(child: Text('构造将要广播的待签名交易'), onPressed: actionBuildData2sign),
        ],
      ),
    );
  }
}
