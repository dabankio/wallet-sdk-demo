import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/shared/widgets/copy_btn.dart';

import 'request_create_multisig.dart';
import 'request_transfer.dart';

class AddrDetail extends StatefulWidget {
  static const routeName = "addrs/detail";
  final AddrInfo addrInfo;

  const AddrDetail({Key key, this.addrInfo}) : super(key: key);

  @override
  _AddrDetailState createState() => _AddrDetailState();
}

class _AddrDetailState extends State<AddrDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int balance = -1;
  double balanceETH = -1;
  bool balanceInited = false;

  String message;

  void fetchBalance() async {
    setState(() {
      message = '读取余额';
    });
    String ret = await EthRpc.getBalance(widget.addrInfo.addr, null);
    message = null;
    if (!mounted) {
      return;
    }
    setState(() {
      balance = int.parse(ret.substring(2), radix: 16);
      balanceETH = balance / 1000000000000000000;
      balanceInited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(fetchBalance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('地址详情')),
      body: ListView(
        children: <Widget>[
          if (message != null) Column(children: <Widget>[LinearProgressIndicator(), Text(message)]),
          Row(children: <Widget>[
            Expanded(child: Text('地址:${widget.addrInfo.addr}')),
            CopyBtn(content: widget.addrInfo.addr),
          ]),
          if (widget.addrInfo.isMultisig) Text('多签合约地址', style: TextStyle(color: Colors.blueAccent)),
          Text('余额:$balance(wei)'),
          Text('余额:$balanceETH(ETH)'),
          SizedBox(height: 20),
          RaisedButton(
              child: Text(widget.addrInfo.isMultisig ?? false ? '发起多签转账' : '发起转账'),
              onPressed: !balanceInited
                  ? null
                  : () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => RequestTransfer(
                                currentBalanceETH: balanceETH,
                                addr: widget.addrInfo,
                              )));
                    }),
          if (!widget.addrInfo.isMultisig)
            RaisedButton(
                child: Text('创建多签合约'),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => CreqteMultisigContract(addr0: widget.addrInfo.addr)));
                }),
          SizedBox(height: 80),
          RaisedButton(
              child: Text('链接：ETH ropsten 水龙头'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.addrInfo.addr));
                _scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text('地址已复制,该通知关闭时打开浏览器,下扫可快速关闭通知')))
                    .closed
                    .then((_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => WebviewScaffold(
                              url: "https://faucet.ropsten.be/",
                              appBar: new AppBar(title: new Text("ETH ropsten水龙头")),
                            )),
                  );
                });
              }),
          RaisedButton(
            child: Text('链接：ETH ropsten 浏览器上查看地址'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => WebviewScaffold(
                          url: "https://ropsten.etherscan.io/address/${widget.addrInfo.addr}",
                          appBar: new AppBar(title: new Text("ETH ropsten区块浏览器,addr:${widget.addrInfo.addr}")),
                        )),
              );
            },
          ),
          Text('测试完成后，请把不用的测试ETH返还给水龙头,可发起一笔交易向下述地址转账'),
          RaisedButton(
              child: Text('复制水龙头地址'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '0x687422eea2cb73b5d3e242ba5456b782919afc85'));
                _scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text('已复制(0x687422eea2cb73b5d3e242ba5456b782919afc85)')));
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: fetchBalance,
      ),
    );
  }
}
