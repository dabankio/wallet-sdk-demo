import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:test/test.dart';

void main() {
  test('hex to int', () {
    String s = "0x1d2296e2ff6a3c00";
    print(s.substring(2));
    int i = int.parse(s.substring(2), radix: 16);
    print(i);
    // expect(actual, matcher)
  });

  test('unint8list', () {
    Uint8List list = Uint8List.fromList([1,2,3]);
    var str = list.toString();
    print(str);


    print('-----');
    String s = '0000000000000000000000000000000000000000000000000000000000000000';
    print(hex.decode(s));
  });

  test('sort', () {
    var l = <String>["cd", "6xx", "bcd"];
    print(l.sublist(2));
  });


}