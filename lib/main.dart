import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff0C3150),
          title: Text(
            'SJC',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: GoldListView(),
      ),
    );
  }
}

class GoldListView extends StatefulWidget {
  @override
  _GoldListViewState createState() => _GoldListViewState();
}

class _GoldListViewState extends State<GoldListView> {
  final goldData = <Gold>[];
  final goldStream = StreamController<List<Gold>>();

  void getGoldInfo() async {
    final client = Client();
    const SJC_URL = 'http://sjc.com.vn/giavang/textContent.php';
    final response = await client.get(SJC_URL);

    final document = parse(response.body);
    final trs = document.querySelectorAll("tr");

    for (final tr in trs) {
      final tds = tr.children;
      try {
        goldData.add(
          Gold(
            type: tds[0].text,
            inGold: tds[1].text,
            outGold: tds[2].text,
          ),
        );
      } catch (e) {}
    }

    goldStream.sink.add(goldData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGoldInfo();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    goldStream.close();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Gold>>(
        stream: goldStream.stream,
        initialData: null,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final data = snapshot.data;

          return ListView.separated(
            itemBuilder: (context, index) =>
                _buildGoldInfoRow(data[index], index),
            separatorBuilder: (context, index) => Container(
              height: 2,
              color: const Color(0xffCC9900),
            ),
            itemCount: data.length,
          );
        },
      ),
    );
  }

  Widget _buildGoldInfoRow(Gold gold, int index) {
    //416c7e
    return Container(
      height: 70,
      color: const Color(0xff0C3150),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              gold.type,
              style: TextStyle(
                color: const Color(0xffFBF203),
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
          Expanded(
            child: Container(
              height: 70,
              color: const Color(0xff416c7e),
              child: Center(
                child: Text(
                  gold.inGold,
                  style: TextStyle(
                    color: index == 0 ? const Color(0xffFBF203) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 70,
              color: const Color(0xff416c7e),
              child: Center(
                child: Text(
                  gold.outGold,
                  style: TextStyle(
                    color: index == 0 ? const Color(0xffFBF203) : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Gold {
  String type;
  String inGold;
  String outGold;

  Gold({this.type, this.inGold, this.outGold});
}
