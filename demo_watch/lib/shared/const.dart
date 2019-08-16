const CHAIN_ID = 3;
const ETH18 = 1000000000000000000;
const APP_URL_SCHEMA = 'demoapp://';

const PATH_REQ_SIGN_CONTENT = 'reqsign/';
const PATH_REQ_SIGN_CONTENT_CREATEMULTISIGCONTRACT = 'createmultisig/';
const PATH_REQ_SIGN_CONTENT_ETHTRANSFER = 'ethtransfer/';
const PATH_REQ_SIGN_CONTENT_MULTISIGEXECUTE = 'multisigexecute/';

const PATH_SIGNED_DATA = '';

const PATH_PRIVATEKEY = 'prvkey/';
const PATH_ADDR = 'addr/';
const PATH_PUBKEY = 'pubkey/';
const PATH_RAWTX = 'rawtx/';
const PATH_PART = 'part/'; //eg, part:1/3:rawtx:...
const PATH_SIGNED = 'signed/';

String trimLeftUrlSchema(String url) {
  if (url == null) {
    return url;
  }
  if (!url.startsWith(APP_URL_SCHEMA)) {
    return url;
  }
  return url.substring(APP_URL_SCHEMA.length);
}

String urlWithAppSchema(String path) {
  return APP_URL_SCHEMA + path;
}
