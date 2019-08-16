## add json support
```
part 'addr.g.dart';

@JsonSerializable()

#add default constructor

factory AddrInfo.fromJson(Map<String, dynamic> json) => _$AddrInfoFromJson(json);
Map<String, dynamic> toJson() => _$AddrInfoToJson(this);
```