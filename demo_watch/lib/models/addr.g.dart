// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddrInfo _$AddrInfoFromJson(Map<String, dynamic> json) {
  return AddrInfo()
    ..addr = json['addr'] as String
    ..isMultisig = json['isMultisig'] as bool
    ..sigRequired = json['sigRequired'] as int
    ..memberAddrs = (json['memberAddrs'] as List)?.map((e) => e as String)?.toList()
    ..pendingTxid = json['pendingTxid'] as String;
}

Map<String, dynamic> _$AddrInfoToJson(AddrInfo instance) => <String, dynamic>{
      'addr': instance.addr,
      'isMultisig': instance.isMultisig,
      'sigRequired': instance.sigRequired,
      'memberAddrs': instance.memberAddrs,
      'pendingTxid': instance.pendingTxid
    };
