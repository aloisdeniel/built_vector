import 'package:code_builder/code_builder.dart';
import 'package:built_vector/model.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:dart_style/dart_style.dart';
import 'package:recase/recase.dart';

abstract class Generator {
  String generate(Assets assets);
}

class FlutterGenerator extends Generator {
  String generate(Assets assets) {
    var library = Library((b) => b
      ..directives.addAll([
        Directive.import("package:flutter/widgets.dart"),
      ])
      ..body.add(Class((b) => b
        ..name = ReCase(assets.name).pascalCase
        ..methods.addAll(assets.vectors.map(_generateVector))))
    );
    var emitter = DartEmitter();
    var source = '${library.accept(emitter)}';
    return DartFormatter().format(source);
  }

  Method _generateVector(Vector vector) {

    var tx = _toFixedDouble(-vector.viewBox.x);
    var ty = _toFixedDouble(-vector.viewBox.y);
    var sx = "(size.width / ${_toFixedDouble(vector.viewBox.width)})";
    var sy = "(size.height / ${_toFixedDouble(vector.viewBox.height)})";

    var body = <Code>[
      Code("canvas.translate(${tx}, ${ty});"),
      Code("canvas.scale(${sx}, ${sy});"),
      Code("final paint = Paint();"),
      Code("if(fill != null) {"),
      Code("paint.color = fill;"),
      Code("}"),
    ];
    
    vector.fills.forEach((s) => _generateShape(body, s));
    return Method((b) => b
      ..name = ReCase(vector.name).camelCase
      ..body = Block((b) => b..statements.addAll(body))
      ..static = true
      ..optionalParameters.addAll([
        Parameter((p) => p
          ..type = refer("Color")
          ..named = true
          ..defaultTo = Code("null")
          ..name = "fill"),
      ])
      ..requiredParameters.addAll([
        Parameter((p) => p
          ..type = refer("Canvas")
          ..name = "canvas"),
        Parameter((p) => p
          ..type = refer("Size")
          ..name = "size"),
      ])
    );
  }

  void _generateShape(List<Code> code, Shape shape) {

    _generateBrush(code, shape.fill);

    if(shape is Path) {
      _generatePath(code, shape);
    }
    else if(shape is Rectangle) {
      _generateRect(code, shape);
    }
    else if(shape is Circle) {
      _generateCircle(code, shape);
    }
  }

  void _generateRect(List<Code> code, Rectangle rect) {
    var instance = "Rect.fromLTWH(${_toFixedDouble(rect.x)}, ${_toFixedDouble(rect.y)}, ${_toFixedDouble(rect.width)}, ${_toFixedDouble(rect.height)})";
    code.add(Code("canvas.drawRect((" + instance + "), paint);"));
  }

  void _generateCircle(List<Code> code, Circle circle) {
      code.add(Code("canvas.drawCircle(Offset(${_toFixedDouble(circle.centerX)}, ${_toFixedDouble(circle.centerY)}), ${_toFixedDouble(circle.radius)}, paint);"));
  }

  void _generatePath(List<Code> code, Path path) {
    var buffer = StringBuffer();
    var proxy = _FlutterPathProxy(buffer);
    writeSvgPathDataToPath(path.data, proxy);
    code.add(Code("canvas.drawPath((" + buffer.toString() + "), paint);"));
  }


  void _generateBrush(List<Code> code, Brush brush) {
    if(brush != null) {
      code.add(Code("if(fill == null) {"));

      if(brush is Color) {
        var color = 'Color(0x${brush.value.toRadixString(16).padLeft(8, '0')})';
        code.add(Code("paint.color = $color;"));
      }

      code.add(Code("}"));
    }
  }
}

class _FlutterPathProxy extends PathProxy {
  final StringBuffer statements;

  _FlutterPathProxy(this.statements) {
    this.statements.write("Path()");
  }

  @override
  void close() => this.statements.write("..close()");

  @override
  void cubicTo(
          double x1, double y1, double x2, double y2, double x3, double y3) =>
      statements.write(
          "..cubicTo(${_toFixedDouble(x1)}, ${_toFixedDouble(y1)}, ${_toFixedDouble(x2)}, ${_toFixedDouble(y2)}, ${_toFixedDouble(x3)}, ${_toFixedDouble(y3)})");

  @override
  void lineTo(double x, double y) => statements
      .write("..lineTo(${_toFixedDouble(x)}, ${_toFixedDouble(y)})");

  @override
  void moveTo(double x, double y) => statements
      .write("..moveTo(${_toFixedDouble(x)}, ${_toFixedDouble(y)})");
}

String _toFixedDouble(double value) {
  if (value == 0) return "0.0";
  return value.toStringAsFixed(6);
}
