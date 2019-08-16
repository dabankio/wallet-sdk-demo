import 'package:convert/convert.dart';
import 'package:demo_watch/shared/const.dart';
import 'package:demo_watch/shared/utl.dart';
import 'package:demo_watch/shared/widgets/paste_or_scan.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/sdk/sdk_wrapper.dart';
import 'package:demo_watch/shared/req_sign_content.dart';

import 'request_sign.dart';

class RequestTransfer extends StatefulWidget {
  final double currentBalanceETH;
  final AddrInfo addr;

  const RequestTransfer({Key key, this.currentBalanceETH, this.addr}) : super(key: key);
  @override
  _RequestTransferState createState() => _RequestTransferState();
}

class _RequestTransferState extends State<RequestTransfer> {
  final TextEditingController toAddrCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  String message;

  String broadcastAddress; //广播交易的地址,多签用

  void actionChangeBroadcaster() {
    for (int i = 0; i < widget.addr.memberAddrs.length * 2; i++) {
      int idx = i % widget.addr.memberAddrs.length;
      if (widget.addr.memberAddrs[idx] == broadcastAddress) {
        int nextIdx = ((i + 1) % widget.addr.memberAddrs.length);
        setState(() {
          broadcastAddress = widget.addr.memberAddrs[nextIdx];
        });
        break;
      }
    }
  }

  void setToAddr(String v) {
    if (v == null) {
      return;
    }
    v = trimLeftUrlSchema(v);
    v = utlTrimLeft(v, PATH_ADDR);
    setState(() {
      toAddrCtrl.text = v;
    });
  }

  void actionGenerateToSignData(BuildContext ctx) async {
    String toAddress = toAddrCtrl.text;
    double amount = double.tryParse(amountCtrl.text);
    if (toAddress == null || amount == null) {
      showToast('似乎转出地址或金额没有正确设置', backgroundColor: Colors.redAccent);
      return;
    }
    if (toAddress.length < 40 || toAddress.length > 42) {
      showToast('似乎不是合法地址', backgroundColor: Colors.redAccent);
      return;
    }
    if (amount > widget.currentBalanceETH) {
      showToast('转出金额超过了余额', backgroundColor: Colors.redAccent);
      return;
    }
    setState(() {
      message = '获取nonce,gasPrice,gasLimit';
    });
    var nonceGaspriceGaslimit = await EthRpc.getNonceGaspriceGaslimit(widget.addr.addr);
    if (!mounted) {
      return;
    }
    setState(() {
      message = null;
    });
    var nonce = nonceGaspriceGaslimit[0];
    var gasPrice = nonceGaspriceGaslimit[1];
    var gasLimit = nonceGaspriceGaslimit[2];
    ReqSignContent reqSign;

    if (!widget.addr.isMultisig) {
      reqSign = ReqSignContentETHTransfer()
        ..amount = amount
        ..toAddress = toAddress
        ..gasLimit = gasLimit
        ..gasPrice = gasPrice
        ..nonce = nonce;
    } else {
      setState(() {
        message = '读取合约内部nonce';
      });
      var packedNonce = await SdkWrapper.simpleMultisigAbiPackedNonce();
      var internalNonceData = await EthRpc.call(widget.addr.addr, packedNonce);
      var internalNonce = await SdkWrapper.simpleMultisigAbiUnpackedNonce(hex.decode(internalNonceData.substring(2)));
      reqSign = ReqSignContentMultisigExecute()
        ..multisigContractAddress = widget.addr.addr
        ..toAddress = toAddress
        ..internalNonce = internalNonce
        ..amount = amount
        ..exectorAddress = broadcastAddress
        ..gasLimit = gasLimit;
      setState(() {
        message = null;
      });
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RequestSignPage(
              content: reqSign,
              addr: widget.addr,
            )));
  }

  @override
  void initState() {
    super.initState();
    if (widget.addr.isMultisig) {
      broadcastAddress = widget.addr.memberAddrs[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('发起转账')),
      body: ListView(children: <Widget>[
        if (message != null) Column(children: <Widget>[LinearProgressIndicator(), Text(message)]),
        Center(child: Text('当前余额(ETH):${widget.currentBalanceETH}')),
        SizedBox(height: 16),
        Row(children: <Widget>[
          Expanded(child: TextField(controller: toAddrCtrl, decoration: InputDecoration(labelText: '转出地址'))),
          PasteOrScan(callback: setToAddr),
        ]),
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: '转出金额(ETH)'),
        ),
        if (widget.addr.isMultisig)
          Row(children: <Widget>[
            Text('广播者：'),
            Expanded(child: Text(broadcastAddress)),
            RaisedButton(child: Text('更换'), onPressed: actionChangeBroadcaster),
          ]),
        SizedBox(height: 16),
        RaisedButton(
          child: Text('生成待签名数据'),
          onPressed: () => actionGenerateToSignData(context),
        ),
      ]),
    );
  }
}
