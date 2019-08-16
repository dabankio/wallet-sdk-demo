import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../const.dart';

class PagedQrImage extends StatefulWidget {
  final String data;

  const PagedQrImage({Key key, this.data}) : super(key: key);

  @override
  _PagedQrImageState createState() => _PagedQrImageState();
}

class _PagedQrImageState extends State<PagedQrImage> {
  int currentIndex = 0;
  int p;
  List<String> parts = [];

  @override
  void initState() {
    super.initState();
    if (widget.data.length < 850) {
      return;
    }
    const perPart = 845;
    p = (widget.data.length / perPart).ceil();
    parts = [];
    for (int i = 0; i < p; i++) {
      int end = (i + 1) * perPart;
      if (end > widget.data.length) {
        end = widget.data.length;
      }
      // part/1-2/...
      parts.add('$PATH_PART$i-$p/' + widget.data.substring(i * perPart, end));
    }
  }

  void actionChangeIndex(int idx) {
    setState(() {
      currentIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.length < 100) {
      return QrImage(version: 5, data: widget.data);
    }

    if (widget.data.length < 200) {
      return QrImage(version: 9, data: widget.data);
    }

    if (widget.data.length < 500) {
      return QrImage(version: 9, data: widget.data);
    }

    if (widget.data.length < 850) {
      return QrImage(version: 20, data: widget.data);
    }

    // 858

    return Container(
      // color: Colors.grey,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width + 72),
        child: Column(
          children: <Widget>[
            QrImage(version: 20, data: parts[currentIndex]),
            Text('part: ${currentIndex + 1} - $p (len:${parts[currentIndex].length})', style: TextStyle(fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                    child: Text('上一页'),
                    onPressed: currentIndex == 0
                        ? null
                        : () {
                            actionChangeIndex(currentIndex - 1);
                          }),
                Text('当前第 ${currentIndex + 1} - ${parts.length} 页'),
                RaisedButton(
                  child: Text('下一页'),
                  onPressed: (currentIndex == parts.length - 1)
                      ? null
                      : () {
                          actionChangeIndex(currentIndex + 1);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
