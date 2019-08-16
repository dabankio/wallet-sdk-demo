import 'dart:async';

import 'package:demo_watch/shared/req_sign_content.dart';
import 'package:demo_watch/ui/broadcast_result.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:demo_watch/repo/addrs.dart';
import 'package:demo_watch/shared/const.dart';
import 'package:demo_watch/models/addr.dart';
import 'package:demo_watch/shared/widgets/action_import_data.dart';
import 'addr_detail.dart';

class AddrList extends StatefulWidget {
  static const routeName = "/addrlist";

  @override
  _AddrListState createState() => _AddrListState();
}

class _AddrListState extends State<AddrList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<AddrInfo> addrs = [];

  void loadAddrs() async {
    var ret = await AddrRepo.loadAll();
    setState(() {
      addrs = ret;
    });
  }

  void actionImportAddr() async {
    String addr = await readImportData(_scaffoldKey.currentContext);
    if (addr == null) {
      return;
    }
    if (!addr.startsWith(PATH_ADDR)) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Err:地址没有以$PATH_ADDR 开头 -> $addr'),
      ));
      return;
    }

    String a = addr.substring(PATH_ADDR.length);
    if (addrs.any((ad) => ad.addr == a)) {
      showToast('已经导入的地址');
      return;
    }
    var ret = await AddrRepo.add(AddrInfo()
      ..addr = a
      ..isMultisig = false);
    setState(() {
      addrs = ret;
    });
  }

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(loadAddrs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('地址列表')),
      body: ListView(
        children: <Widget>[
          for (var addr in addrs.where((add) => add.addr != null)) //已有地址的
            ListTile(
              title: Text(addr.addr),
              subtitle: addr.isMultisig ? Text('多签', style: TextStyle(color: Colors.blue)) : Text('地址'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: RouteSettings(name: AddrDetail.routeName),
                      builder: (context) => AddrDetail(addrInfo: addr)),
                ).then((_) {
                  loadAddrs();
                });
                // _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('to detail')));
              },
            ),
          for (var addr in addrs.where((add) => add.addr == null && add.pendingTxid != null))
            ListTile(
              title: Text('pending 的创建多签地址交易,尚无地址', style: TextStyle(color: Colors.deepOrangeAccent)),
              subtitle: Text('txid:' + addr.pendingTxid),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BroadcastResult(
                            reqSign: ReqSignContentCreateMultisigContract()
                              ..sigRequired = addr.sigRequired
                              ..addrs = addr.memberAddrs,
                            txid: addr.pendingTxid,
                          )),
                ).then((_) {
                  loadAddrs();
                });
              },
            ),
          RaisedButton(child: Text('导入观察地址'), onPressed: actionImportAddr),
          RaisedButton(
            child: Text('全部清除'),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text('确定清除?'),
                        content: Text('注意多签地址清除后不可恢复，虽然是测试环境，还是把币转出后再清除！'),
                        actions: <Widget>[
                          FlatButton(
                              child: Text('清除'),
                              onPressed: () async {
                                await AddrRepo.clear();
                                Navigator.pop(ctx);
                                loadAddrs();
                              }),
                          FlatButton(child: Text('不清除'), onPressed: () => Navigator.pop(ctx)),
                        ],
                      ));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: loadAddrs,
      ),
    );
  }
}
