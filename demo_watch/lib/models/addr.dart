import 'package:json_annotation/json_annotation.dart';

part 'addr.g.dart';

@JsonSerializable()
class AddrInfo {
  String addr;
  bool isMultisig;

  //多签用
  int sigRequired;
  List<String> memberAddrs;
  String pendingTxid; //创建多签交易时的pending txid,不为空时表示还没打包不能获取合约地址

  AddrInfo();

  factory AddrInfo.fromJson(Map<String, dynamic> json) => _$AddrInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AddrInfoToJson(this);
}
