part of svgaplayer_flutter_player;

class SVGASimpleImage extends StatefulWidget {
  String resUrl;
  String assetsName;

  SVGASimpleImage({this.resUrl, this.assetsName});

  @override
  State<StatefulWidget> createState() {
    return _SVGASimpleImageState(
        resUrl: this.resUrl, assetsName: this.assetsName);
  }
}

class _SVGASimpleImageState extends State<SVGASimpleImage>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController animationController;

  _SVGASimpleImageState({String resUrl, String assetsName}) {
    if (resUrl != null) {
      SVGAParser.shared.decodeFromURL(resUrl).then((videoItem) {
        this.animationController
          ..videoItem = videoItem
          ..repeat();
      });
    } else if (assetsName != null) {
      SVGAParser.shared.decodeFromAssets(assetsName).then((videoItem) {
        this.animationController
          ..videoItem = videoItem
          ..repeat();
      });
    }
  }

  @override
  void initState() {
    this.animationController = SVGAAnimationController(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SVGAImage(this.animationController);
  }
}
