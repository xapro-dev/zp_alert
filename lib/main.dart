import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:libwinmedia/libwinmedia.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _enabled = true;
  Array list = new Array(1);
  bool _alerted = false;

  late Player player;

  @override
  void initState() {
    super.initState();
    player = Player(id: 0);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  _MyHomePageState() {
    _polling();
  }

  void _togglePolling() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _enabled = !_enabled;
    });
  }

  Future<void> _alert() async {
    // final player = AudioPlayer();
    // player.play(Uint8List.fromList("Hello".codeUnits));
    // final player = AudioPlayer();
    Media media = Media(uri: "https://sounds-mp3.com/mp3/0012433.mp3");
    player.open([media]);
    player.play();
    // await player.seek(Duration(seconds: 10));
    // await player.pause();
  }

  Future<void> _polling() async {
    while (true) {
      if (_enabled) {
        var url = Uri.parse(
            'https://emapa.fra1.cdn.digitaloceanspaces.com/statuses.json');
        var response = await http.get(url);
        var enabled_at = jsonDecode(utf8.decode(response.bodyBytes))['states']
            ['Запорізька область']['enabled_at'];
        // var enabled_at = "";
        if (enabled_at != null) {
          if (!_alerted) {
            await _alert();
            _alerted = true;
          }
        } else {
          _alerted = false;
        }
        break;
      }
      await Future.delayed(Duration(seconds: 15));
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              _enabled ? "enabled" : "disabled",
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _togglePolling,
        tooltip: 'Increment',
        child: Text(_enabled ? "disable" : "enable"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
