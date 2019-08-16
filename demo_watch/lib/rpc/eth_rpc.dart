import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;

class EthRpc {
  static const defaultRpcUrl = "https://ropsten.infura.io/v3/69f29be376784f37b36a146ce7581efc";
  static String rpcUrl = defaultRpcUrl;

  static Map<String, dynamic> invoke(String method, dynamic args) {
    Map<String, dynamic> m = {"jsonrpc": "2.0", "method": method, "params": args, "id": 1};
    print('rpc: ' + jsonEncode(m));
    return m;
  }

  static Future<String> getBalance(String address, String block) async {
    var resp = await http.post(
      rpcUrl,
      body: jsonEncode(invoke("eth_getBalance", [address, block ?? "latest"])),
    );
    if (resp.statusCode != 200) {
      print(resp.body);
      return "<${resp.statusCode}>";
    }
    Map<String, dynamic> m = jsonDecode(resp.body);
    return m['result'];
  }

  static Future<int> getTransactionCount(String address, String block) async {
    var resp =
        await http.post(rpcUrl, body: jsonEncode(invoke('eth_getTransactionCount', [address, block ?? 'latest'])));
    if (resp.statusCode != 200) {
      print(resp.body);
      return -1;
    }
    Map<String, dynamic> m = jsonDecode(resp.body);
    return int.parse(m['result'].substring(2), radix: 16);
  }

  static Future<int> getSuggestedGasPrice() async {
    var resp = await http.post(rpcUrl, body: jsonEncode(invoke('eth_gasPrice', [])));
    if (resp.statusCode != 200) {
      print(resp.body);
      return -1;
    }
    Map<String, dynamic> m = jsonDecode(resp.body);
    return int.parse(m['result'].substring(2), radix: 16);
  }

  static Future<Map<String, dynamic>> getBlockByNumber(int id, bool txDetail) async {
    var resp =
        await http.post(rpcUrl, body: jsonEncode(invoke('eth_getBlockByNumber', [id ?? 'latest', txDetail ?? false])));
    if (resp.statusCode != 200) {
      throw resp;
    }
    Map<String, dynamic> m = jsonDecode(resp.body);
    if (m['result'] == null) {
      throw resp.body;
    }
    print(resp.body);
    return m['result'];
  }

  static Future<String> sendRawTransaction(String tx) async {
    var resp = await http.post(rpcUrl, body: jsonEncode(invoke('eth_sendRawTransaction', [tx])));
    if (resp.statusCode != 200) {
      print(resp.body);
      return 'http_err_code: ${resp.statusCode}';
    }
    print(resp.body);
    Map<String, dynamic> m = jsonDecode(resp.body);
    var ret = m['result'];
    if (ret == null) {
      throw resp.body;
    }
    return ret;
  }

  static Future<Map<String, dynamic>> getTransactionReceipt(String txid) async {
    var resp = await http.post(rpcUrl, body: jsonEncode(invoke('eth_getTransactionReceipt', [txid])));
    if (resp.statusCode != 200) {
      print(resp.body);
      throw 'http_err_code: ${resp.statusCode}\n${resp.body}';
    }
    Map<String, dynamic> m = jsonDecode(resp.body);
    var ret = m['result'];
    // if (ret == null) {
    //   throw resp.body;
    // }
    return ret;
  }

  static Future<List<int>> getNonceGaspriceGaslimit(String addr) async {
    var nonce = await getTransactionCount(addr, null);
    var gasPrice = await getSuggestedGasPrice();
    gasPrice = (gasPrice * 3).ceil(); //加倍
    var block = await getBlockByNumber(null, null);
    var gasLimit = int.parse(block['gasLimit'].substring(2), radix: 16) - 1000;
    return [nonce, gasPrice, gasLimit];
  }

  static Future<String> call(String to, Uint8List data) async {
    Map<String, dynamic> m = {
      'to': to,
      'data': '0x' + hex.encode(data), //0xaffed0e0
    };
    var resp = await http.post(rpcUrl, body: jsonEncode(invoke('eth_call', [m, 'latest'])));
    if (resp.statusCode != 200) {
      throw resp;
    }
    print(resp.body);
    Map<String, dynamic> rm = jsonDecode(resp.body);
    var ret = rm['result'];
    if (ret == null) {
      throw resp.body;
    }
    return ret;
  }
}
