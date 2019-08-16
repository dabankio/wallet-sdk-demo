class Addr {
  String privateKey; //私钥
  String publicKey; //公钥
  String address; //地址

  static Addr decode(String prvPubAddr) {
    var l = prvPubAddr.split(',');
    return Addr()
      ..privateKey = l[0]
      ..publicKey = l[1]
      ..address = l[2];
  }

  String encode() {
    return '$privateKey,$publicKey,$address';
  }
}
