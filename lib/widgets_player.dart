library svgaplayer_flutter_player_widgets;

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'proto/svga.pbserver.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart' as m;
import 'package:path_drawing/path_drawing.dart';

class SVGAWidgets extends StatefulWidget {
  final SVGAWidgetsAnimationController _controller;
  final BoxFit fit;
  final bool clearsAfterStop;
  final double width;
  final double height;

  SVGAWidgets(
      this._controller, {
        this.fit = BoxFit.contain,
        this.clearsAfterStop = true,
        this.width = 300,
        this.height = 300,
      });

  @override
  State<StatefulWidget> createState() {
    return _SVGAWidgetsState(this._controller,
        clearsAfterStop: this.clearsAfterStop);
  }
}

class SVGAWidgetsAnimationController extends AnimationController {
  MovieEntity _videoItem;
  bool _canvasNeedsClear = false;

  SVGAWidgetsAnimationController({@required TickerProvider vsync})
      : super(vsync: vsync);

  set videoItem(MovieEntity value) {
    this.stop();
    this.clear();
    this._videoItem = value;
    if (value != null) {
      this.duration = Duration(
          milliseconds: (this._videoItem.params.frames /
              this._videoItem.params.fps *
              1000)
              .toInt());
    } else {
      this.duration = Duration(milliseconds: 0);
    }
  }

  MovieEntity get videoItem => this._videoItem;

  void clear() {
    this._canvasNeedsClear = true;
    this.notifyListeners();
  }
}

class _SVGAWidgetsState extends State<SVGAWidgets> {
  final SVGAWidgetsAnimationController _animationController;
  final bool clearsAfterStop;

  _SVGAWidgetsState(this._animationController, {this.clearsAfterStop}) {
    this._animationController.addListener(() {
      this.setState(() {});
    });
    this._animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && this.clearsAfterStop) {
        this._animationController.clear();
      }
    });
  }
  Map<String, List<ShapeEntity>> shapeCache = {};

  @override
  Widget build(BuildContext context) {
    if (this._animationController.videoItem == null) {
      return Container();
    }
    final needsClear = this._animationController._canvasNeedsClear;
    this._animationController._canvasNeedsClear = false;
    return SVGAWidgetsTree(
      treeData: _animationController.videoItem,
      currentFrame: SVGAWidgetsPainter.calculateCurrentFrame(this._animationController.videoItem,
          this._animationController.value),
      fit: this.widget.fit,
      width: widget.width,
      height: widget.height,
      shapeCache: shapeCache,
    );
    return CustomPaint(
      painter: new SVGAWidgetsPainter(
        this._animationController.videoItem,
        SVGAWidgetsPainter.calculateCurrentFrame(this._animationController.videoItem,
            this._animationController.value),
        fit: this.widget.fit,
        clear: needsClear,
      ),
      size: Size(
        this.widget._controller.videoItem.params.viewBoxWidth,
        this.widget._controller.videoItem.params.viewBoxHeight,
      ),
    );
  }
}


class SVGAWidgetsTree extends StatefulWidget {
  final MovieEntity treeData;
  final int currentFrame;
  final BoxFit fit;
  final double width;
  final double height;
  final Map<String, List<ShapeEntity>> shapeCache;
  SVGAWidgetsTree({this.treeData, this.currentFrame, this.fit, this.width, this.height, this.shapeCache});

  @override
  _SVGAWidgetsTreeState createState() => _SVGAWidgetsTreeState();
}

class _SVGAWidgetsTreeState extends State<SVGAWidgetsTree> {
  MovieEntity get treeData => widget.treeData;
  int get currentFrame => widget.currentFrame;
  BoxFit get fit => widget.fit;

  @override
  void initState() {
    super.initState();
    debugPrint(widget.treeData.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: treeData.params.viewBoxHeight,
      width: treeData.params.viewBoxWidth,
      color: m.Colors.green,
      child: scaleToFit(child: drawShape()),
    );
  }
  static const _validMethods = 'MLHVCSQRZmlhvcsqrz';
  Path buildDPath(String argD, {Path path}) {
    if (treeData.pathCache[argD] != null) {
      return treeData.pathCache[argD];
    }
    if (path == null) {
      path = Path();
    }
    final d = argD.replaceAllMapped(RegExp('([a-zA-Z])'), (match) {
      return "|||${match.group(1)} ";
    }).replaceAll(RegExp(","), " ");
    var currentPointX = 0.0;
    var currentPointY = 0.0;
    double currentPointX1;
    double currentPointY1;
    double currentPointX2;
    double currentPointY2;
    d.split("|||").forEach((segment) {
      if (segment.length == 0) {
        return;
      }
      final firstLetter = segment.substring(0, 1);
      if (_validMethods.indexOf(firstLetter) >= 0) {
        final args = segment.substring(1).trim().split(" ");
        if (firstLetter == "M") {
          currentPointX = double.parse(args[0]);
          currentPointY = double.parse(args[1]);
          path.moveTo(currentPointX, currentPointY);
        } else if (firstLetter == "m") {
          currentPointX += double.parse(args[0]);
          currentPointY += double.parse(args[1]);
          path.moveTo(currentPointX, currentPointY);
        } else if (firstLetter == "L") {
          currentPointX = double.parse(args[0]);
          currentPointY = double.parse(args[1]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "l") {
          currentPointX += double.parse(args[0]);
          currentPointY += double.parse(args[1]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "H") {
          currentPointX = double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "h") {
          currentPointX += double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "V") {
          currentPointY = double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "v") {
          currentPointY += double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "C") {
          currentPointX1 = double.parse(args[0]);
          currentPointY1 = double.parse(args[1]);
          currentPointX2 = double.parse(args[2]);
          currentPointY2 = double.parse(args[3]);
          currentPointX = double.parse(args[4]);
          currentPointY = double.parse(args[5]);
          path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
              currentPointY2, currentPointX, currentPointY);
        } else if (firstLetter == "c") {
          currentPointX1 = currentPointX + double.parse(args[0]);
          currentPointY1 = currentPointY + double.parse(args[1]);
          currentPointX2 = currentPointX + double.parse(args[2]);
          currentPointY2 = currentPointY + double.parse(args[3]);
          currentPointX += double.parse(args[4]);
          currentPointY += double.parse(args[5]);
          path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
              currentPointY2, currentPointX, currentPointY);
        } else if (firstLetter == "S") {
          if (currentPointX1 != null &&
              currentPointY1 != null &&
              currentPointX2 != null &&
              currentPointY2 != null) {
            currentPointX1 = currentPointX - currentPointX2 + currentPointX;
            currentPointY1 = currentPointY - currentPointY2 + currentPointY;
            currentPointX2 = double.parse(args[0]);
            currentPointY2 = double.parse(args[1]);
            currentPointX = double.parse(args[2]);
            currentPointY = double.parse(args[3]);
            path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
                currentPointY2, currentPointX, currentPointY);
          } else {
            currentPointX1 = double.parse(args[0]);
            currentPointY1 = double.parse(args[1]);
            currentPointX = double.parse(args[2]);
            currentPointY = double.parse(args[3]);
            path.quadraticBezierTo(
                currentPointX1, currentPointY1, currentPointX, currentPointY);
          }
        } else if (firstLetter == "s") {
          if (currentPointX1 != null &&
              currentPointY1 != null &&
              currentPointX2 != null &&
              currentPointY2 != null) {
            currentPointX1 = currentPointX - currentPointX2 + currentPointX;
            currentPointY1 = currentPointY - currentPointY2 + currentPointY;
            currentPointX2 = currentPointX + double.parse(args[0]);
            currentPointY2 = currentPointY + double.parse(args[1]);
            currentPointX += double.parse(args[2]);
            currentPointY += double.parse(args[3]);
            path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
                currentPointY2, currentPointX, currentPointY);
          } else {
            currentPointX1 = currentPointX + double.parse(args[0]);
            currentPointY1 = currentPointY + double.parse(args[1]);
            currentPointX += double.parse(args[2]);
            currentPointY += double.parse(args[3]);
            path.quadraticBezierTo(
                currentPointX1, currentPointY1, currentPointX, currentPointY);
          }
        } else if (firstLetter == "Q") {
          currentPointX1 = double.parse(args[0]);
          currentPointY1 = double.parse(args[1]);
          currentPointX = double.parse(args[2]);
          currentPointY = double.parse(args[3]);
          path.quadraticBezierTo(
              currentPointX1, currentPointY1, currentPointX, currentPointY);
        } else if (firstLetter == "q") {
          currentPointX1 = currentPointX + double.parse(args[0]);
          currentPointY1 = currentPointY + double.parse(args[1]);
          currentPointX += double.parse(args[2]);
          currentPointY += double.parse(args[3]);
          path.quadraticBezierTo(
              currentPointX1, currentPointY1, currentPointX, currentPointY);
        } else if (firstLetter == "Z" || firstLetter == "z") {
          path.close();
        }
      }
      treeData.pathCache[argD] = path;
    });
    return path;
  }
  Path buildPath(ShapeEntity shape) {
    final path = Path();
    if (shape.type == ShapeEntity_ShapeType.SHAPE) {
      final args = shape.shape;
      final argD = args.d ?? "";
      return this.buildDPath(argD, path: path);
    } else if (shape.type == ShapeEntity_ShapeType.ELLIPSE) {
      final args = shape.ellipse;
      final xv = args.x ?? 0.0;
      final yv = args.y ?? 0.0;
      final rxv = args.radiusX ?? 0.0;
      final ryv = args.radiusY ?? 0.0;
      path.addOval(Rect.fromLTWH(xv - rxv, yv - ryv, rxv * 2, ryv * 2));
    } else if (shape.type == ShapeEntity_ShapeType.RECT) {
      final args = shape.rect;
      final xv = args.x ?? 0.0;
      final yv = args.y ?? 0.0;
      final wv = args.width ?? 0.0;
      final hv = args.height ?? 0.0;
      final crv = args.cornerRadius ?? 0.0;
      path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(xv, yv, wv, hv), Radius.circular(crv)));
    }
    return path;
  }
  Color colorFromFill(fill, alpha) {
    return Color.fromARGB(
            (fill.a * alpha * 255).toInt(),
            (fill.r * 255).toInt(),
            (fill.g * 255).toInt(),
            (fill.b * 255).toInt(),
          );
  }
  Widget scaleToFit({Widget child, Canvas canvas}) {
    Size size = m.Size(widget.width, widget.height);
    final double imageWidth = treeData.params.viewBoxWidth.toDouble();
    final double imageHeight = treeData.params.viewBoxHeight.toDouble();
    if (imageWidth == 0.0 ||
        imageHeight == 0.0 ||
        size.width == 0.0 ||
        size.height == 0.0) return Container();
    switch (this.fit) {
      case BoxFit.contain:
        if (imageWidth / imageHeight >= size.width / size.height) {
          child = m.Transform.translate(offset: m.Offset(
            0.0,
            (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
          ),
            child: child,
          );
          child = m.Transform.scale(scale: size.width / imageWidth,
            child: child,
          );
        } else {
          child = m.Transform.translate(offset: m.Offset(
            (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
            0.0,
          ),
            child: child,
          );
          child = m.Transform.scale(scale: size.height / imageHeight,
            child: child,
          );
        }
        break;
      case BoxFit.cover:
        if (imageWidth / imageHeight <= size.width / size.height) {
          canvas.translate(
            0.0,
            (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
          );
          canvas.scale(size.width / imageWidth, size.width / imageWidth);
        } else {
          canvas.translate(
            (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
            0.0,
          );
          canvas.scale(size.height / imageHeight, size.height / imageHeight);
        }
        break;
      case BoxFit.fill:
        canvas.scale(size.width / imageWidth, size.height / imageHeight);
        break;
      case BoxFit.fitWidth:
        canvas.translate(
          0.0,
          (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
        );
        canvas.scale(size.width / imageWidth, size.width / imageWidth);
        break;
      case BoxFit.fitHeight:
        canvas.translate(
          (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
          0.0,
        );
        canvas.scale(size.height / imageHeight, size.height / imageHeight);
        break;
      case BoxFit.none:
        canvas.translate(
          (size.width - imageWidth) / 2.0,
          (size.height - imageHeight) / 2.0,
        );
        break;
      case BoxFit.scaleDown:
        if (imageWidth > size.width || imageHeight > size.height) {
          if (imageWidth / imageHeight >= size.width / size.height) {
            canvas.translate(
              0.0,
              (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
            );
            canvas.scale(size.width / imageWidth, size.width / imageWidth);
          } else {
            canvas.translate(
              (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
              0.0,
            );
            canvas.scale(size.height / imageHeight, size.height / imageHeight);
          }
        }
        break;
      default:
    }
    return child;
  }
  Map<String, List<ShapeEntity>> get shapeCache => widget.shapeCache;
  Widget drawShape() {
    Widget finalStack;
    List<Widget> theStackElements = [];
    treeData.sprites.forEach((sprite) {
      if (sprite.imageKey != null &&
          treeData.dynamicItem.dynamicHidden[sprite.imageKey] == true)
        return;
      if (shapeCache[sprite.imageKey] == null) shapeCache[sprite.imageKey] = [];
      final frameItem = sprite.frames[this.currentFrame];
//      print('painting frame ${currentFrame} for ${sprite.imageKey}');
      if (currentFrame > 0 && theStackElements.length > 0) {
        frameItem.shapes = shapeCache[sprite.imageKey];
      } else {
        shapeCache[sprite.imageKey] = frameItem.shapes;
      }
      if (frameItem.shapes == null || frameItem.shapes.length == 0) return;

      double width = 0;
      double height = 0;
      double left = 0;
      double top = 0;
      Color fillColor;
      frameItem.shapes.forEach((ShapeEntity shape) {
        final path = this.buildPath(shape);
        fillColor = colorFromFill(shape.styles.fill, frameItem.alpha);
        width = shape.rect.width;
        height = shape.rect.height;
        left = shape.rect.x;
        top = shape.rect.y;
        if (shape.hasTransform()) {
          width *= shape.transform.a;
          height *= shape.transform.d;
          left += shape.transform.tx;
          top += shape.transform.ty;
//          var shapeMatrix = Float64List.fromList([
//            shape.transform.a,
//            shape.transform.b,
//            0.0,
//            0.0,
//            shape.transform.c,
//            shape.transform.d,
//            0.0,
//            0.0,
//            0.0,
//            0.0,
//            1.0,
//            0.0,
//            shape.transform.tx,
//            shape.transform.ty,
//            0.0,
//            1.0
//          ].toList());
//          container = m.Transform(
//            transform: Matrix4.fromFloat64List(shapeMatrix),
//            child: container,
//          );
        }
        if (frameItem.hasClipPath()) {
          // TODO get another clipPath
//          canvas.clipPath(this.buildDPath(frameItem.clipPath));
        }
//        container = Positioned(
//          left: -shape.rect.x,
//          top: -shape.rect.y,
//          child: container,
//        );
      });
      if (frameItem.hasTransform()) {
        width *= frameItem.transform.a;
        height *= frameItem.transform.d;
        left += frameItem.transform.tx;
        top += frameItem.transform.ty;
//        var matrix = Float64List.fromList([
//          frameItem.transform.a,
//          frameItem.transform.b,
//          0.0,
//          0.0,
//          frameItem.transform.c,
//          frameItem.transform.d,
//          0.0,
//          0.0,
//          0.0,
//          0.0,
//          1.0,
//          0.0,
//          frameItem.transform.tx,
//          frameItem.transform.ty,
//          0.0,
//          1.0
//        ].toList());
//        finalStack = m.Transform(
//          transform: Matrix4.fromFloat64List(matrix),
//          child: finalStack,
//        );
      }
      Widget container = Positioned(
        width: width,
        height: height,
        left: left,
        top: top,
        child: Container(
          color: fillColor,
        ),
      );
      theStackElements.add(container);
    });
    finalStack = Stack(
      children: theStackElements,
    );
    return finalStack;
  }
}


class SVGAWidgetsPainter extends CustomPainter {
  final MovieEntity videoItem;
  int currentFrame = 0;
  final BoxFit fit;
  final bool clear;

  static int calculateCurrentFrame(
      MovieEntity videoItem, double animationProcess) {
    return min(
      videoItem.params.frames - 1,
      max(0, (videoItem.params.frames.toDouble() * animationProcess).toInt()),
    );
  }

  SVGAWidgetsPainter(this.videoItem, this.currentFrame, {this.fit, this.clear});

  @override
  void paint(Canvas canvas, Size size) {
    if (this.videoItem == null) return;
    if (this.clear == true) return;
    canvas.save();
    this.scaleToFit(canvas, size);
    this.drawBitmap(canvas, size);
    this.drawShape(canvas, size);
    this.drawText(canvas, size);
    canvas.restore();
  }

  void scaleToFit(Canvas canvas, Size size) {
    final double imageWidth = this.videoItem.params.viewBoxWidth.toDouble();
    final double imageHeight = this.videoItem.params.viewBoxHeight.toDouble();
    if (imageWidth == 0.0 ||
        imageHeight == 0.0 ||
        size.width == 0.0 ||
        size.height == 0.0) return;
    switch (this.fit) {
      case BoxFit.contain:
        if (imageWidth / imageHeight >= size.width / size.height) {
          canvas.translate(
            0.0,
            (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
          );
          canvas.scale(size.width / imageWidth, size.width / imageWidth);
        } else {
          canvas.translate(
            (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
            0.0,
          );
          canvas.scale(size.height / imageHeight, size.height / imageHeight);
        }
        break;
      case BoxFit.cover:
        if (imageWidth / imageHeight <= size.width / size.height) {
          canvas.translate(
            0.0,
            (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
          );
          canvas.scale(size.width / imageWidth, size.width / imageWidth);
        } else {
          canvas.translate(
            (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
            0.0,
          );
          canvas.scale(size.height / imageHeight, size.height / imageHeight);
        }
        break;
      case BoxFit.fill:
        canvas.scale(size.width / imageWidth, size.height / imageHeight);
        break;
      case BoxFit.fitWidth:
        canvas.translate(
          0.0,
          (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
        );
        canvas.scale(size.width / imageWidth, size.width / imageWidth);
        break;
      case BoxFit.fitHeight:
        canvas.translate(
          (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
          0.0,
        );
        canvas.scale(size.height / imageHeight, size.height / imageHeight);
        break;
      case BoxFit.none:
        canvas.translate(
          (size.width - imageWidth) / 2.0,
          (size.height - imageHeight) / 2.0,
        );
        break;
      case BoxFit.scaleDown:
        if (imageWidth > size.width || imageHeight > size.height) {
          if (imageWidth / imageHeight >= size.width / size.height) {
            canvas.translate(
              0.0,
              (size.height - (imageHeight * (size.width / imageWidth))) / 2.0,
            );
            canvas.scale(size.width / imageWidth, size.width / imageWidth);
          } else {
            canvas.translate(
              (size.width - (imageWidth * (size.height / imageHeight))) / 2.0,
              0.0,
            );
            canvas.scale(size.height / imageHeight, size.height / imageHeight);
          }
        }
        break;
      default:
    }
  }

  void drawBitmap(Canvas canvas, Size size) {
    this.videoItem.sprites.forEach((sprite) {
      if (sprite.imageKey == null) return;
      if (this.videoItem.dynamicItem.dynamicHidden[sprite.imageKey] == true)
        return;
      final frameItem = sprite.frames[this.currentFrame];
      final bitmap =
          this.videoItem.dynamicItem.dynamicImages[sprite.imageKey] ??
              this.videoItem.bitmapCache[sprite.imageKey];
      if (bitmap == null) return;
      canvas.save();
      if (frameItem.hasTransform()) {
        canvas.transform(Float64List.fromList([
          frameItem.transform.a,
          frameItem.transform.b,
          0.0,
          0.0,
          frameItem.transform.c,
          frameItem.transform.d,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          frameItem.transform.tx,
          frameItem.transform.ty,
          0.0,
          1.0
        ].toList()));
      }
      final bitmapPaint = Paint();
      bitmapPaint.isAntiAlias = true;
      bitmapPaint.color =
          Color.fromARGB((frameItem.alpha * 255.0).toInt(), 255, 255, 255);
      if (frameItem.hasClipPath()) {
        canvas.clipPath(this.buildDPath(frameItem.clipPath));
      }
      canvas.drawImage(bitmap, Offset.zero, bitmapPaint);
      if (this.videoItem.dynamicItem.dynamicDrawer[sprite.imageKey] != null) {
        this.videoItem.dynamicItem.dynamicDrawer[sprite.imageKey](
            canvas, this.currentFrame);
      }
      canvas.restore();
    });
  }

  void drawShape(Canvas canvas, Size size) {
    this.videoItem.sprites.forEach((sprite) {
      if (sprite.imageKey != null &&
          this.videoItem.dynamicItem.dynamicHidden[sprite.imageKey] == true)
        return;
      final frameItem = sprite.frames[this.currentFrame];
      if (frameItem.shapes == null || frameItem.shapes.length == 0) return;
      canvas.save();
      if (frameItem.hasTransform()) {
        canvas.transform(Float64List.fromList([
          frameItem.transform.a,
          frameItem.transform.b,
          0.0,
          0.0,
          frameItem.transform.c,
          frameItem.transform.d,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          frameItem.transform.tx,
          frameItem.transform.ty,
          0.0,
          1.0
        ].toList()));
      }
      frameItem.shapes.forEach((shape) {
        final path = this.buildPath(shape);
        if (shape.hasTransform() || frameItem.hasClipPath()) {
          canvas.save();
        }
        if (shape.hasTransform()) {
          canvas.transform(Float64List.fromList([
            shape.transform.a,
            shape.transform.b,
            0.0,
            0.0,
            shape.transform.c,
            shape.transform.d,
            0.0,
            0.0,
            0.0,
            0.0,
            1.0,
            0.0,
            shape.transform.tx,
            shape.transform.ty,
            0.0,
            1.0
          ].toList()));
        }
        if (frameItem.hasClipPath()) {
          canvas.clipPath(this.buildDPath(frameItem.clipPath));
        }
        final fill = shape.styles?.fill;
        if (fill != null) {
          final paint = Paint();
          paint.isAntiAlias = true;
          paint.style = PaintingStyle.fill;
          paint.color = Color.fromARGB(
            (fill.a * frameItem.alpha * 255).toInt(),
            (fill.r * 255).toInt(),
            (fill.g * 255).toInt(),
            (fill.b * 255).toInt(),
          );
          canvas.drawPath(path, paint);
        }
        final strokeWidth = shape.styles?.strokeWidth;
        if (strokeWidth != null && strokeWidth > 0) {
          final paint = Paint();
          paint.style = PaintingStyle.stroke;
          if (shape.styles.stroke != null) {
            paint.color = Color.fromARGB(
              (shape.styles.stroke.a * frameItem.alpha * 255).toInt(),
              (shape.styles.stroke.r * 255).toInt(),
              (shape.styles.stroke.g * 255).toInt(),
              (shape.styles.stroke.b * 255).toInt(),
            );
          }
          paint.strokeWidth = strokeWidth;
          final lineCap = shape.styles?.lineCap;
          if (lineCap != null) {
            switch (lineCap) {
              case ShapeEntity_ShapeStyle_LineCap.LineCap_BUTT:
                paint.strokeCap = StrokeCap.butt;
                break;
              case ShapeEntity_ShapeStyle_LineCap.LineCap_ROUND:
                paint.strokeCap = StrokeCap.round;
                break;
              case ShapeEntity_ShapeStyle_LineCap.LineCap_SQUARE:
                paint.strokeCap = StrokeCap.square;
                break;
              default:
            }
          }
          final lineJoin = shape.styles?.lineJoin;
          if (lineJoin != null) {
            switch (lineJoin) {
              case ShapeEntity_ShapeStyle_LineJoin.LineJoin_MITER:
                paint.strokeJoin = StrokeJoin.miter;
                break;
              case ShapeEntity_ShapeStyle_LineJoin.LineJoin_ROUND:
                paint.strokeJoin = StrokeJoin.round;
                break;
              case ShapeEntity_ShapeStyle_LineJoin.LineJoin_BEVEL:
                paint.strokeJoin = StrokeJoin.bevel;
                break;
              default:
            }
          }
          paint.strokeMiterLimit = shape.styles?.miterLimit ?? 0.0;
          List<double> lineDash = [
            shape.styles?.lineDashI ?? 0.0,
            shape.styles?.lineDashII ?? 0.0,
            shape.styles?.lineDashIII ?? 0.0
          ];
          if (lineDash[0] > 0 || lineDash[1] > 0) {
            canvas.drawPath(
                dashPath(
                  path,
                  dashArray: CircularIntervalList([
                    lineDash[0] < 1.0 ? 1.0 : lineDash[0],
                    lineDash[1] < 0.1 ? 0.1 : lineDash[1],
                  ]),
                  dashOffset: DashOffset.absolute(lineDash[2]),
                ),
                paint);
          } else {
            canvas.drawPath(path, paint);
          }
          if (sprite.imageKey != null &&
              this.videoItem.dynamicItem.dynamicDrawer[sprite.imageKey] !=
                  null) {
            this.videoItem.dynamicItem.dynamicDrawer[sprite.imageKey](
                canvas, this.currentFrame);
          }
        }
        if (shape.hasTransform() || frameItem.hasClipPath()) {
          canvas.restore();
        }
      });
      canvas.restore();
    });
  }

  static const _validMethods = 'MLHVCSQRZmlhvcsqrz';

  Path buildPath(ShapeEntity shape) {
    final path = Path();
    if (shape.type == ShapeEntity_ShapeType.SHAPE) {
      final args = shape.shape;
      final argD = args.d ?? "";
      return this.buildDPath(argD, path: path);
    } else if (shape.type == ShapeEntity_ShapeType.ELLIPSE) {
      final args = shape.ellipse;
      final xv = args.x ?? 0.0;
      final yv = args.y ?? 0.0;
      final rxv = args.radiusX ?? 0.0;
      final ryv = args.radiusY ?? 0.0;
      path.addOval(Rect.fromLTWH(xv - rxv, yv - ryv, rxv * 2, ryv * 2));
    } else if (shape.type == ShapeEntity_ShapeType.RECT) {
      final args = shape.rect;
      final xv = args.x ?? 0.0;
      final yv = args.y ?? 0.0;
      final wv = args.width ?? 0.0;
      final hv = args.height ?? 0.0;
      final crv = args.cornerRadius ?? 0.0;
      path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(xv, yv, wv, hv), Radius.circular(crv)));
    }
    return path;
  }

  Path buildDPath(String argD, {Path path}) {
    if (this.videoItem.pathCache[argD] != null) {
      return this.videoItem.pathCache[argD];
    }
    if (path == null) {
      path = Path();
    }
    final d = argD.replaceAllMapped(RegExp('([a-zA-Z])'), (match) {
      return "|||${match.group(1)} ";
    }).replaceAll(RegExp(","), " ");
    var currentPointX = 0.0;
    var currentPointY = 0.0;
    double currentPointX1;
    double currentPointY1;
    double currentPointX2;
    double currentPointY2;
    d.split("|||").forEach((segment) {
      if (segment.length == 0) {
        return;
      }
      final firstLetter = segment.substring(0, 1);
      if (_validMethods.indexOf(firstLetter) >= 0) {
        final args = segment.substring(1).trim().split(" ");
        if (firstLetter == "M") {
          currentPointX = double.parse(args[0]);
          currentPointY = double.parse(args[1]);
          path.moveTo(currentPointX, currentPointY);
        } else if (firstLetter == "m") {
          currentPointX += double.parse(args[0]);
          currentPointY += double.parse(args[1]);
          path.moveTo(currentPointX, currentPointY);
        } else if (firstLetter == "L") {
          currentPointX = double.parse(args[0]);
          currentPointY = double.parse(args[1]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "l") {
          currentPointX += double.parse(args[0]);
          currentPointY += double.parse(args[1]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "H") {
          currentPointX = double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "h") {
          currentPointX += double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "V") {
          currentPointY = double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "v") {
          currentPointY += double.parse(args[0]);
          path.lineTo(currentPointX, currentPointY);
        } else if (firstLetter == "C") {
          currentPointX1 = double.parse(args[0]);
          currentPointY1 = double.parse(args[1]);
          currentPointX2 = double.parse(args[2]);
          currentPointY2 = double.parse(args[3]);
          currentPointX = double.parse(args[4]);
          currentPointY = double.parse(args[5]);
          path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
              currentPointY2, currentPointX, currentPointY);
        } else if (firstLetter == "c") {
          currentPointX1 = currentPointX + double.parse(args[0]);
          currentPointY1 = currentPointY + double.parse(args[1]);
          currentPointX2 = currentPointX + double.parse(args[2]);
          currentPointY2 = currentPointY + double.parse(args[3]);
          currentPointX += double.parse(args[4]);
          currentPointY += double.parse(args[5]);
          path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
              currentPointY2, currentPointX, currentPointY);
        } else if (firstLetter == "S") {
          if (currentPointX1 != null &&
              currentPointY1 != null &&
              currentPointX2 != null &&
              currentPointY2 != null) {
            currentPointX1 = currentPointX - currentPointX2 + currentPointX;
            currentPointY1 = currentPointY - currentPointY2 + currentPointY;
            currentPointX2 = double.parse(args[0]);
            currentPointY2 = double.parse(args[1]);
            currentPointX = double.parse(args[2]);
            currentPointY = double.parse(args[3]);
            path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
                currentPointY2, currentPointX, currentPointY);
          } else {
            currentPointX1 = double.parse(args[0]);
            currentPointY1 = double.parse(args[1]);
            currentPointX = double.parse(args[2]);
            currentPointY = double.parse(args[3]);
            path.quadraticBezierTo(
                currentPointX1, currentPointY1, currentPointX, currentPointY);
          }
        } else if (firstLetter == "s") {
          if (currentPointX1 != null &&
              currentPointY1 != null &&
              currentPointX2 != null &&
              currentPointY2 != null) {
            currentPointX1 = currentPointX - currentPointX2 + currentPointX;
            currentPointY1 = currentPointY - currentPointY2 + currentPointY;
            currentPointX2 = currentPointX + double.parse(args[0]);
            currentPointY2 = currentPointY + double.parse(args[1]);
            currentPointX += double.parse(args[2]);
            currentPointY += double.parse(args[3]);
            path.cubicTo(currentPointX1, currentPointY1, currentPointX2,
                currentPointY2, currentPointX, currentPointY);
          } else {
            currentPointX1 = currentPointX + double.parse(args[0]);
            currentPointY1 = currentPointY + double.parse(args[1]);
            currentPointX += double.parse(args[2]);
            currentPointY += double.parse(args[3]);
            path.quadraticBezierTo(
                currentPointX1, currentPointY1, currentPointX, currentPointY);
          }
        } else if (firstLetter == "Q") {
          currentPointX1 = double.parse(args[0]);
          currentPointY1 = double.parse(args[1]);
          currentPointX = double.parse(args[2]);
          currentPointY = double.parse(args[3]);
          path.quadraticBezierTo(
              currentPointX1, currentPointY1, currentPointX, currentPointY);
        } else if (firstLetter == "q") {
          currentPointX1 = currentPointX + double.parse(args[0]);
          currentPointY1 = currentPointY + double.parse(args[1]);
          currentPointX += double.parse(args[2]);
          currentPointY += double.parse(args[3]);
          path.quadraticBezierTo(
              currentPointX1, currentPointY1, currentPointX, currentPointY);
        } else if (firstLetter == "Z" || firstLetter == "z") {
          path.close();
        }
      }
      this.videoItem.pathCache[argD] = path;
    });
    return path;
  }

  void drawText(Canvas canvas, Size size) {
    if (this.videoItem.dynamicItem.dynamicText.length == 0) return;
    this.videoItem.sprites.forEach((sprite) {
      if (sprite.imageKey == null) return;
      if (this.videoItem.dynamicItem.dynamicHidden[sprite.imageKey] == true)
        return;
      if (this.videoItem.dynamicItem.dynamicText[sprite.imageKey] == null)
        return;
      final frameItem = sprite.frames[this.currentFrame];
      if (sprite.imageKey == "banner") {
        canvas.save();
        if (frameItem.hasTransform()) {
          canvas.transform(Float64List.fromList([
            frameItem.transform.a,
            frameItem.transform.b,
            0.0,
            0.0,
            frameItem.transform.c,
            frameItem.transform.d,
            0.0,
            0.0,
            0.0,
            0.0,
            1.0,
            0.0,
            frameItem.transform.tx,
            frameItem.transform.ty,
            0.0,
            1.0
          ].toList()));
        }
        TextPainter textPainter =
        this.videoItem.dynamicItem.dynamicText[sprite.imageKey];
        textPainter.paint(
            canvas,
            Offset(
              (frameItem.layout.width - textPainter.width) / 2.0,
              (frameItem.layout.height - textPainter.height) / 2.0,
            ));
        canvas.restore();
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (this.clear == true) {
      return true;
    } else if (oldDelegate is SVGAWidgetsPainter) {
      return !(oldDelegate.videoItem == this.videoItem &&
          oldDelegate.currentFrame == this.currentFrame);
    }
    return true;
  }
}
