import 'dart:typed_data';

import 'package:flutter/services.dart';

class SdkWrapper {
  static const platform = const MethodChannel('walletcore/eth');

  static Future<String> buildTime() async {
    String ret = await platform.invokeMethod('buildTime');
    return ret;
  }

  static Future<Uint8List> simpleMultisigAbiPackedNonce() async {
    Uint8List ret = await platform.invokeMethod('simpleMultisigAbiPackedNonce');
    return ret;
  }

  static Future<int> simpleMultisigAbiUnpackedNonce(List<int> result) async {
    int ret = await platform.invokeMethod('simpleMultisigAbiUnpackedNonce', result);
    return ret;
  }

  static Future<Uint8List> simpleMultisigPackedExecute({
    String toAddress,
    double amount,
    Uint8List data,
    int gasLimit,
    String executor,
    List<String> sortedSigs, //按照签名地址升序排序
  }) async {
    Uint8List ret = await platform.invokeMethod('simpleMultisigPackedExecute', <String, dynamic>{
      'toAddress': toAddress,
      'amount': amount,
      'data': data,
      'gasLimit': gasLimit,
      'sigs': sortedSigs,
      'executor': executor,
    });
    return ret;
  }
}
