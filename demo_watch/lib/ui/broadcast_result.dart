import 'dart:convert';

import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/repo/addrs.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:demo_watch/shared/widgets/copy_btn.dart';
import 'package:demo_watch/shared/widgets/split_line_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:oktoast/oktoast.dart';

import 'addr_list.dart';

class BroadcastResult extends StatefulWidget {
  final ReqSignContent reqSign;
  final String txid;

  const BroadcastResult({Key key, @required this.reqSign, this.txid}) : super(key: key);
  @override
  _BroadcastResultState createState() => _BroadcastResultState();
}

class _BroadcastResultState extends State<BroadcastResult> {
  String loadingMessage;
  String contractAddress;

  void actionFetchCreatedContractAddress() async {
    setState(() {
      loadingMessage = '读取交易';
    });
    var m = await EthRpc.getTransactionReceipt(widget.txid);
    setState(() {
      loadingMessage = null;
    });
    if (m == null) {
      showToast('没有读取到交易数据，可能还在pending中,去浏览器看看吧', duration: Duration(seconds: 8));
      return;
    }
    var addr = m['contractAddress'];
    if (addr == null) {
      throw '空的合约地址：' + jsonEncode(m);
    }
    print('----contact addr:$addr');
    setState(() {
      contractAddress = addr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('交易已广播')),
      body: ListView(
        children: <Widget>[
          if (loadingMessage != null) Column(children: <Widget>[LinearProgressIndicator(), Text(loadingMessage)]),
          Center(child: Text(widget.reqSign.title())),
          SplitLineText(widget.reqSign.info()),
          Row(children: <Widget>[
            Expanded(child: Text('txid:${widget.txid}')),
            CopyBtn(content: widget.txid),
            RaisedButton(
              child: Text('浏览交易'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebviewScaffold(
                      url: "https://ropsten.etherscan.io/tx/${widget.txid}",
                      appBar: new AppBar(title: new Text("浏览交易")),
                    ),
                  ),
                );
              },
            )
          ]),
          if (widget.reqSign is ReqSignContentCreateMultisigContract && contractAddress == null) ...[
            Row(children: <Widget>[
              RaisedButton(child: Text('读取合约地址'), onPressed: actionFetchCreatedContractAddress),
              Text('(确保交易成功后读取,读取后存下来:-)'),
            ]),
            RaisedButton(
              child: Text('暂存交易id,稍后从地址列表页读取'),
              onPressed: () async {
                ReqSignContentCreateMultisigContract reqCreate = widget.reqSign;
                await AddrRepo.add(AddrInfo()
                  ..isMultisig = true
                  ..pendingTxid = widget.txid
                  ..sigRequired = reqCreate.sigRequired
                  ..memberAddrs = reqCreate.addrs);
                showToast('保存成功,可以在列表页找到', backgroundColor: Colors.lightBlue);
                Navigator.of(context).popUntil((r) => r.settings.name == AddrList.routeName);
              },
            )
          ],
          if (contractAddress != null && widget.reqSign is ReqSignContentCreateMultisigContract)
            Row(children: <Widget>[
              Expanded(child: Text('合约地址：$contractAddress')),
              RaisedButton(
                child: Text('浏览地址'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WebviewScaffold(
                        url: "https://ropsten.etherscan.io/address/$contractAddress",
                        appBar: new AppBar(title: new Text("浏览地址")),
                      ),
                    ),
                  );
                },
              ),
              RaisedButton(
                child: Text('保存地址'),
                onPressed: () async {
                  ReqSignContentCreateMultisigContract reqCreate = widget.reqSign;
                  AddrRepo.add(AddrInfo()
                    ..pendingTxid = widget.txid
                    ..addr = contractAddress
                    ..isMultisig = true
                    ..sigRequired = reqCreate.sigRequired
                    ..memberAddrs = reqCreate.addrs);
                  showToast('保存成功', backgroundColor: Colors.lightBlue);
                },
              )
            ])
        ],
      ),
    );
  }
}
