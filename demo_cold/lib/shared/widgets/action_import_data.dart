import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

import '../const.dart';

const int FromClipboard = 1;
const int FromCamera = 2;
const int CancelAction = 0;

/// 读取导入数据从二维码或者剪切板
Future<String> readImportData(BuildContext ctx, {int source}) async {
  int fromSource;

  if (source != null) {
    fromSource = source;
  } else {
    fromSource = await showModalBottomSheet<int>(
      context: ctx,
      builder: (c) => ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Text('读取剪贴板'),
            onPressed: () => Navigator.of(c).pop(FromClipboard),
          ),
          FlatButton(
            child: Text('扫码'),
            onPressed: () => Navigator.of(c).pop(FromCamera),
          ),
          FlatButton(
            child: Text('取消'),
            onPressed: () => Navigator.of(c).pop(CancelAction),
          )
        ],
      ),
    );
  }

  if (fromSource == null || fromSource == CancelAction) {
    return null;
  }

  String readAddr;
  if (fromSource == FromClipboard) {
    readAddr = (await Clipboard.getData("text/plain")).text;
    return readAddr;
  }

  if (fromSource == FromCamera) {
    String ret = await scanQRCode();

    if (ret == null || !ret.startsWith(PATH_PART)) {
      return ret;
    }

    // 如果包含多页，则以第一页的总共页数为依据，一直读取，直到全部扫码完成
    int totalPage = -1;
    List<String> pages = [];
    // part/1-3/${data}
    while (pages.length == 0 || pages.contains(null)) {
      var partPageData = ret.split('/');
      String data = partPageData.sublist(2).join('/');
      var indexTotalString = partPageData[1].split('-');

      if (totalPage == -1) {
        totalPage = int.parse(indexTotalString[1]);
        pages = List.generate(totalPage, (_) => null);
      }

      int currentIndex = int.parse(indexTotalString[0]);
      print('currentindex  $currentIndex, pages length:${pages.length}');
      if (pages[currentIndex] == null) {
        pages[currentIndex] = data;
        print('readed:$ret');
      }

      List<int> scanedPages = [];
      List<int> notScanedPages = [];
      for (int i = 0; i < totalPage; i++) {
        if (pages[i] != null) {
          scanedPages.add(i + 1);
        } else {
          notScanedPages.add(i + 1);
        }
      }
      showToast('已获取第$scanedPages 页\n剩余第 $notScanedPages 页');
      if (notScanedPages.length == 0) {
        break;
      }
      await Future.delayed(const Duration(seconds: 2), () => null); //睡眠1s
      ret = await scanQRCode();
    }
    return pages.join('');
  }
  return null;
}

Future<String> scanQRCode() {
  return QRCodeReader()
      .setAutoFocusIntervalInMs(500) // default 5000
      .setForceAutoFocus(true) // default false
      .setTorchEnabled(true) // default false
      .setHandlePermissions(true) // default true
      .setExecuteAfterPermissionGranted(true) // default true
      .scan();
}
