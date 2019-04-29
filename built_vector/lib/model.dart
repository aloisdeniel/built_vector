import 'package:meta/meta.dart';

class Assets {
  final String name;
  final List<Vector> vectors;
  final List<Definition> definitions;
  Assets(
      {@required this.name,
      this.vectors = const <Vector>[],
      this.definitions = const <Definition>[]});
}

class ViewBox {
  final double x;
  final double y;
  final double width;
  final double height;
  ViewBox(
      {@required this.x,
      @required this.y,
      @required this.width,
      @required this.height});
}

class Vector {
  final String name;
  final Brush fill;
  final ViewBox viewBox;
  final List<Shape> fills;
  Vector(
      {@required this.name,
      @required this.fill,
      @required this.viewBox,
      this.fills = const <Shape>[]});
}

abstract class Brush {}

class Color implements Brush {
  final int value;
  Color(this.value);
}

abstract class Shape {
  final Brush fill;
  Shape({@required this.fill});
}

class Path extends Shape {
  final String data;
  Path({@required Brush fill, @required this.data}) : super(fill: fill);
}

class Circle extends Shape {
  final double centerX;
  final double centerY;
  final double radius;
  Circle({Brush fill, this.centerX, this.centerY, this.radius})
      : super(fill: fill);
}

class Rectangle extends Shape {
  final double x;
  final double y;
  final double width;
  final double height;
  Rectangle(
      {@required Brush fill,
      @required this.x,
      @required this.y,
      @required this.width,
      @required this.height})
      : super(fill: fill);
}

abstract class Definition {
  final String id;
  Definition({@required this.id});
}

class LinearGradient extends Definition {
  final double x1, x2, y1, y2;
  final List<GradientStop> stops;
  LinearGradient(
      {@required String id,
      @required this.x1,
      @required this.x2,
      @required this.y1,
      @required this.y2,
      this.stops = const <GradientStop>[]})
      : super(id: id);
}

class Offset {
  final double amount;
  Offset(this.amount);
}

class GradientStop {
  final Offset offset;
  final double opacity;
  final Color color;
  GradientStop(
      {@required this.color, this.opacity = 1.0, @required this.offset});
}
