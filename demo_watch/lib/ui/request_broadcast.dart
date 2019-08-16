// 请求广播交易页面
import 'package:demo_watch/ui/broadcast_result.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:demo_watch/shared/widgets/split_line_text.dart';

class RequestBroadcastPage extends StatefulWidget {
  final String rawSignedData;
  final ReqSignContent reqSign;

  const RequestBroadcastPage({Key key, this.rawSignedData, this.reqSign}) : super(key: key);
  @override
  _RequestBroadcastPageState createState() => _RequestBroadcastPageState();
}

class _RequestBroadcastPageState extends State<RequestBroadcastPage> {
  String loadingMessage;

  void actionBroadcastTx(BuildContext ctx) async {
    setState(() {
      loadingMessage = '广播交易中';
    });
    String txid = await EthRpc.sendRawTransaction(widget.rawSignedData);
    setState(() {
      loadingMessage = null;
    });
    showToast('交易已广播');
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (c) => BroadcastResult(reqSign: widget.reqSign, txid: txid),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('已签名交易')),
      body: ListView(children: <Widget>[
        if (loadingMessage != null) Column(children: <Widget>[LinearProgressIndicator(), Text(loadingMessage)]),
        Center(child: Text(widget.reqSign.title())),
        SplitLineText(widget.reqSign.info()),
        Text('已签名的原始交易(Length:${widget.rawSignedData.length}):'),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 180),
          child: Scrollbar(child: SingleChildScrollView(child: Text(widget.rawSignedData))),
        ),
        SizedBox(height: 24),
        RaisedButton(
          child: Text('广播交易'),
          onPressed: () => actionBroadcastTx(context),
        ),
        SizedBox(height: 36),
      ]),
    );
  }
}
