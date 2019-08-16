import 'dart:convert';
import 'dart:typed_data';

import 'const.dart';

ReqSignContent parseReqSignContent(String encodedContentWithPrefix) {
  encodedContentWithPrefix = trimLeftUrlSchema(encodedContentWithPrefix);
  if (!encodedContentWithPrefix.startsWith(PATH_REQ_SIGN_CONTENT)) {
    throw 'not start with $PATH_REQ_SIGN_CONTENT';
  }

  String content = encodedContentWithPrefix.substring(PATH_REQ_SIGN_CONTENT.length);

  if (content.startsWith(PATH_REQ_SIGN_CONTENT_CREATEMULTISIGCONTRACT)) {
    var req = ReqSignContentCreateMultisigContract();
    req.decode(content);
    return req;
  } else if (content.startsWith(PATH_REQ_SIGN_CONTENT_ETHTRANSFER)) {
    var req = ReqSignContentETHTransfer();
    req.decode(content);
    return req;
  } else if (content.startsWith(PATH_REQ_SIGN_CONTENT_MULTISIGEXECUTE)) {
    var req = ReqSignContentMultisigExecute();
    req.decode(content);
    return req;
  } else {
    throw 'unknown req sign content';
  }
}

abstract class ReqSignContent {
  String title();
  String encode(); //用于展示二维码
  void decode(String content); //扫码
  String info(); //详细描述
}

/// 创建多签合约
class ReqSignContentCreateMultisigContract implements ReqSignContent {
  int nonce;
  int sigRequired;
  int gasPrice;
  int gasLimit;
  List<String> addrs;

  @override
  void decode(String content) {
    var items = content.substring(PATH_REQ_SIGN_CONTENT_CREATEMULTISIGCONTRACT.length).split(",");
    nonce = int.parse(items[0]);
    sigRequired = int.parse(items[1]);
    gasPrice = int.parse(items[2]);
    gasLimit = int.parse(items[3]);
    addrs = items.sublist(4);
  }

  @override
  String encode() {
    List<String> list = [
      nonce.toString(),
      sigRequired.toString(),
      gasPrice.toString(),
      gasLimit.toString(),
      ...addrs,
    ];
    return PATH_REQ_SIGN_CONTENT_CREATEMULTISIGCONTRACT + list.join(",");
  }

  @override
  String info() {
    return '''
nonce: $nonce
签名人数 - 总人数：$sigRequired - 2
gasPrice: $gasPrice
gasLimit: $gasLimit
地址1:  ${addrs[0]}
地址2:  ${addrs[1]}
    ''';
  }

  @override
  String title() {
    return '创建 $sigRequired - 2 多签合约';
  }
}

/// 转账或合约调用
class ReqSignContentETHTransfer implements ReqSignContent {
  int nonce;
  String toAddress;
  double amount;
  int gasLimit;
  int gasPrice;
  Uint8List data;

  @override
  void decode(String content) {
    var items = content.substring(PATH_REQ_SIGN_CONTENT_ETHTRANSFER.length).split(',');
    nonce = int.parse(items[0]);
    toAddress = items[1];
    amount = double.parse(items[2]);
    gasLimit = int.parse(items[3]);
    gasPrice = int.parse(items[4]);
    if (items.length >= 6) {
      data = base64Decode(items[5]);
    }
  }

  @override
  String encode() {
    List<String> items = [
      nonce.toString(),
      toAddress,
      amount.toString(),
      gasLimit.toString(),
      gasPrice.toString(),
      if (data != null) base64Encode(data)
    ];
    return PATH_REQ_SIGN_CONTENT_ETHTRANSFER + items.join(',');
  }

  @override
  String info() {
    return '''
nonce: $nonce,
地址: $toAddress,
金额: $amount,
gasLimit: $gasLimit,
gasPrice: $gasPrice,
data.length: ${data?.length ?? 0}
    ''';
  }

  @override
  String title() {
    return 'ETH 转账 或 合约调用';
  }
}

/// 多签转账签名（不是后续的交易签名
class ReqSignContentMultisigExecute implements ReqSignContent {
  String multisigContractAddress;
  String toAddress;
  int internalNonce;
  double amount; //value
  int gasLimit;
  String exectorAddress; //最终发起交易的人，这里由创建人发起
  // int gasPrice;
  Uint8List data;

  @override
  void decode(String content) {
    var items = content.substring(PATH_REQ_SIGN_CONTENT_MULTISIGEXECUTE.length).split(',');
    multisigContractAddress = items[0];
    toAddress = items[1];
    internalNonce = int.parse(items[2]);
    amount = double.parse(items[3]);
    gasLimit = int.parse(items[4]);
    exectorAddress = items[5];
    if (items.length >= 7) {
      data = base64Decode(items[6]);
    }
  }

  @override
  String encode() {
    List<String> items = [
      multisigContractAddress,
      toAddress,
      internalNonce.toString(),
      amount.toString(),
      gasLimit.toString(),
      exectorAddress,
      if (data != null) base64Encode(data)
    ];
    return PATH_REQ_SIGN_CONTENT_MULTISIGEXECUTE + items.join(',');
  }

  @override
  String info() {
    return '''
多签合约地址: $multisigContractAddress
目标地址: $toAddress
内部nonce: $internalNonce
amount: $amount
gasLimit: $gasLimit
执行/地址: $exectorAddress
data.length: ${data?.length ?? 0}
    ''';
  }

  @override
  String title() {
    return '多签转账原始数据签名';
  }
}
