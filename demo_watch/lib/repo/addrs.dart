import 'dart:convert';

import 'package:demo_watch/models/addr.dart';
import 'package:shared_preferences/shared_preferences.dart';

const KEY_MULTISIG_ADDRS = 'multisig_addrs';
const String STORE_KEY_ADDRS = "k:addrs";

class AddrRepo {
  static Future<List<AddrInfo>> loadAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString(STORE_KEY_ADDRS);

    List<AddrInfo> addrs = [];
    if (json != null) {
      Iterable<dynamic> l = jsonDecode(json);
      if (l != null) {
        addrs = l.map((json) => AddrInfo.fromJson(json)).toList();
      }
    }
    return addrs;
  }

  static Future<void> replace(List<AddrInfo> addrs) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(STORE_KEY_ADDRS);
    prefs.setString(STORE_KEY_ADDRS, jsonEncode(addrs));
  }

  /// 1.增加地址(无txid) 2.增加多签地址(有txid) 3.增加pending中的多签地址（有txid,无addr）
  static Future<List<AddrInfo>> add(AddrInfo newOne) async {
    var list = await loadAll();
    //重复地址不再存储
    if (newOne.addr != null) {
      if (list.any((ad) => ad.addr == newOne.addr)) {
        return list;
      }
    } else {
      //没有地址以txid识别
      if (newOne.pendingTxid != null && list.any((v) => v.pendingTxid == newOne.pendingTxid)) {
        return list;
      }
    }

    //保存多签地址（有txid)时，把旧的移除掉(因为旧的可能pending时暂存还没有地址)
    if (newOne.addr != null && newOne.pendingTxid != null) {
      list.removeWhere((x) => x.pendingTxid == newOne.pendingTxid);
    }

    list.add(newOne);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(STORE_KEY_ADDRS, jsonEncode(list));
    return list;
  }

  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(STORE_KEY_ADDRS);
  }
}
