import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';
import './transition_sample.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  SVGAAnimationController animationController;

  @override
  void initState() {
    this.animationController = SVGAAnimationController(vsync: this);
    this.loadAnimation();
    super.initState();
  }

  @override
  void dispose() {
    this.animationController.dispose();
    super.dispose();
  }

  void loadAnimation() async {
//    final videoItem = await SVGAParser.shared.decodeFromURL(
//        "https://github.com/yyued/SVGA-Samples/blob/master/kingset?raw=true");
    final videoItem = await SVGAParser.shared.decodeFromAssets('assets/angel.svga');
    this.animationController.videoItem = videoItem;
    this
        .animationController
        .repeat()
        .whenComplete(() => this.animationController.videoItem = null);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SVGA sample'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: 500,
            height: 500,
            child: SVGAImage(this.animationController),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TransitionSamplePage()));
            },
            child: Text('Transition sample'),
          ),
        ],
      ),
    );
  }

}
