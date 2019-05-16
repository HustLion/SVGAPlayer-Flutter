import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('SVGA sample'),
        ),
        body: Container(
          child: SVGAImage(this.animationController),
        ),
      ),
    );
  }
}
