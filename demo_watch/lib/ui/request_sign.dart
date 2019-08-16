// 请求签名页面

import 'package:demo_watch/shared/widgets/action_import_data.dart';
import 'package:demo_watch/shared/widgets/paged_qr_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/shared/const.dart';
import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:demo_watch/shared/widgets/copy_btn.dart';
import 'package:demo_watch/shared/widgets/split_line_text.dart';

import 'gather_multisig.dart';
import 'request_broadcast.dart';

class RequestSignPage extends StatefulWidget {
  final ReqSignContent content;
  final AddrInfo addr;

  const RequestSignPage({Key key, this.content, this.addr}) : super(key: key);

  @override
  _RequestSignPageState createState() => _RequestSignPageState();
}

class _RequestSignPageState extends State<RequestSignPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  void parseSignedData(String data) {
    data = trimLeftUrlSchema(data);
    if (!data.startsWith(PATH_SIGNED)) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('err:无法识别的签名数据')));
      return;
    }
    String rawSigned = data.substring(PATH_SIGNED.length);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RequestBroadcastPage(
              rawSignedData: rawSigned,
              reqSign: widget.content,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('待签名数据')),
      body: ListView(
        children: <Widget>[
          Center(child: Text(widget.content.title(), style: TextStyle(fontSize: 22))),
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
          SizedBox(height: 24),
          Text('请用持有私钥的钱包签名'),
          PagedQrImage(data: urlWithAppSchema(PATH_REQ_SIGN_CONTENT + widget.content.encode())),
          SizedBox(height: 70),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 12,
        child: Container(
          height: 48,
          decoration: BoxDecoration(border: Border(top: BorderSide(width: 1, color: Colors.grey))),
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: (widget.content is ReqSignContentMultisigExecute)
              ? RaisedButton(
                  child: Text('收集成员签名'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => GatherMultisigSigPage(
                        content: widget.content,
                        addr: widget.addr,
                      ),
                    ));
                  },
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('扫码签名结果'),
                      onPressed: () async {
                        String data = await readImportData(context, source: FromCamera);
                        parseSignedData(data);
                      },
                    ),
                    // Expanded(child: SizedBox(width: 1)),
                    RaisedButton(
                      child: Text('从剪切板读取签名结果'),
                      onPressed: () async {
                        String data = (await Clipboard.getData('text/plain')).text;
                        parseSignedData(data);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
