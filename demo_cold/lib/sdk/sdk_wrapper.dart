import 'dart:typed_data';

import 'package:demo_cold/shared/const.dart';
import 'package:demo_cold/shared/req_sign_content.dart';
import 'package:flutter/services.dart';

class SdkWrapper {
  static const platform = const MethodChannel('walletcore/eth');

  /// private,public,addr
  static Future<List<String>> genKey(String prvk) async {
    String ret = await platform.invokeMethod('genEthKey', prvk ?? "");
    return ret.split(',');
  }

  static Future<Uint8List> packedDeploySimpleMultiSig(int sigRequired, List<String> addrs, int chainId) async {
    Uint8List ret = await platform.invokeMethod('packedDeploySimpleMultiSig', <String, dynamic>{
      'sigRequired': sigRequired,
      'addrs': addrs,
      'chainId': chainId,
    });
    return ret;
  }

  /// 构造一个多签合约创建交易，并使用私钥对其签名
  static Future<String> newETHTransactionForContractCreationAndSign(
    int nonce,
    int gasLimit,
    int gasPrice,
    Uint8List data,
    String prvkey,
  ) async {
    String ret = await platform.invokeMethod('newETHTransactionForContractCreationAndSign', <String, dynamic>{
      'nonce': nonce,
      'gasLimit': gasLimit,
      'gasPrice': gasPrice,
      'data': data,
      'prvkey': prvkey,
      // "toAddress": toAddress,
    });
    return ret;
  }

  static Future<String> newTransactionAndSign(
    int nonce,
    int gasLimit,
    int gasPrice,
    String toAddress,
    String prvkey,
    double amount,
    Uint8List data,
  ) async {
    String ret = await platform.invokeMethod('newTransactionAndSign', <String, dynamic>{
      'nonce': nonce,
      'gasLimit': gasLimit,
      'gasPrice': gasPrice,
      'toAddress': toAddress,
      'prvkey': prvkey,
      'amount': amount,
      'data': data,
    });
    return ret;
  }

  static Future<String> signMultisigExecute(ReqSignContentMultisigExecute call, String prvk, int chainId) async {
    double amountInWei = call.amount * ETH18;
    String ret = await platform.invokeMethod('signMultisigExecute', <String, dynamic>{
      'prvkey': prvk,
      'multisigContractAddress': call.multisigContractAddress,
      'toAddress': call.toAddress,
      'internalNonce': call.internalNonce,
      'amount': amountInWei,
      'gasLimit': call.gasLimit,
      'executor': call.exectorAddress,
      'data': call.data,
      'chainId': chainId,
    });
    return ret;
  }

  static Future<String> sign(String data, String prvk) async {
    String ret = await platform.invokeMethod('sign', <String, dynamic>{});
    return ret;
  }
}
