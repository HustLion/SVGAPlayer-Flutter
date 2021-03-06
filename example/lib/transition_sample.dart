import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter/svgaplayer_flutter.dart';

class TransitionSamplePage extends StatefulWidget {
  @override
  _TransitionSamplePageState createState() => _TransitionSamplePageState();
}

class _TransitionSamplePageState extends State<TransitionSamplePage> with TickerProviderStateMixin{
  SVGAWidgetsAnimationController animationController;

  @override
  void initState() {
    this.animationController = SVGAWidgetsAnimationController(vsync: this);
    this.loadAnimation();
    super.initState();
  }

  @override
  void dispose() {
    this.animationController.dispose();
    super.dispose();
  }

  void loadAnimation() async {
    final videoItem = await SVGAParser.shared.decodeFromAssets('assets/transition.svga');
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
        title: Text('Transition sample'),
      ),
      body: Center(
        child: Container(
//          height: 1624 / 3,
//          width: 750 / 3,
          child: SVGAWidgets(animationController,
            width: 750 / 3,
            height: 1624 / 3,
          )
        ),
      ),

    );
  }
}

