class Assets {
  final String name;
  final List<Vector> vectors;
  Assets(this.name, this.vectors);
}

class ViewBox {
  final double x;
  final double y;
  final double width;
  final double height;
  ViewBox(this.x, this.y, this.width, this.height);
}

class Vector {
  final String name;
  final Brush fill;
  final ViewBox viewBox;
  final List<Shape> fills;
  Vector(this.name, this.fill, this.viewBox, this.fills);
}

abstract class Brush {}

class Color implements Brush {
  final int value;
  Color(this.value);
}

abstract class Shape {
  final Brush fill;
  Shape(this.fill);
}

class Path extends Shape {
  final String data;
  Path(Brush fill, this.data) : super(fill);
}

class Circle extends Shape {
  final double centerX;
  final double centerY;
  final double radius;
  Circle(Brush fill, this.centerX, this.centerY, this.radius) : super(fill);
}

class Rectangle extends Shape {
  final double x;
  final double y;
  final double width;
  final double height;
  Rectangle(Brush fill, this.x, this.y, this.width, this.height) : super(fill);
}