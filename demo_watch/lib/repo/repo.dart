import 'package:demo_watch/rpc/eth_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repo {
  static const String KEY_RPC_URL = 'key/rpcurl';
  static Future<String> getRPCUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_RPC_URL) ?? EthRpc.defaultRpcUrl;
  }

  static Future<void> setRPCUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(KEY_RPC_URL, url);
  }
}
