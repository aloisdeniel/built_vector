import 'package:built_vector/model.dart';
import 'package:xml/xml.dart' as xml;

Iterable<xml.XmlElement> _childElements(xml.XmlElement element) =>
    element.children.where((x) => x is xml.XmlElement).cast<xml.XmlElement>();

class AssetsParser {
  AssetsParser();

  Assets parse(String content) {
    if (content != null && content.isNotEmpty) {
      var document = xml.parse(content);
      var rootElement = document.rootElement;

      if (rootElement?.name.toString() == 'assets') {
        var name = rootElement.getAttribute("name");
        assert(name != null, "a name must be precised for assets");
        var definitions = rootElement
            .findElements('defs')
            .expand((x) => _childElements(x).map(_parseDefinition));

        var vectors =
            rootElement.findElements('vector').map(_parseVector).toList();
        return Assets(name: name, vectors: vectors, definitions: definitions);
      }
    }

    return null;
  }

  Definition _parseDefinition(xml.XmlElement element) {
    var id = element.getAttribute("id");
    assert(id != null, "an id must be precised for definitions");

    if (element.name.toString() == "linearGradient") {
      var x1 = element.getAttribute("x1") ?? "0.0";
      var x2 = element.getAttribute("x2") ?? "0.0";
      var y1 = element.getAttribute("y1") ?? "0.0";
      var y2 = element.getAttribute("y2") ?? "1.0";
      return LinearGradient(
          id: id,
          x1: double.parse(x1),
          x2: double.parse(x2),
          y1: double.parse(y1),
          y2: double.parse(y2),
          stops: element.findAllElements("stop").map(_parseGradientStop));
    }

    return null;
  }

  GradientStop _parseGradientStop(xml.XmlElement element) {
    var color = element.getAttribute("stop-color") ?? "#000000";
    var offset = element.getAttribute("offset") ?? "0.0";
    var opacity = element.getAttribute("stop-opacity") ?? "1.0";
    return GradientStop(
        color: Color(_parseColor(color)),
        offset: _parseOffset(offset),
        opacity: double.parse(opacity ?? "1.0"));
  }

  Offset _parseOffset(String value) {
    if (value == null) return Offset(0.0);
    value = value.trim();
    if (value.endsWith("%")) {
      return Offset(double.parse(value.substring(0, value.length - 1)) / 100.0);
    }
    return Offset(double.parse(value));
  }

  Vector _parseVector(xml.XmlElement element) {
    var name = element.getAttribute("name");
    var fill = _parseBrush(element.getAttribute("fill")) ?? Color(0xFF000000);
    var viewBox = _parseViewBox(element.getAttribute("viewBox"));
    assert(name != null, "a name must be precised for each vector");
    assert(viewBox != null, "a viewBox must be precised for each vector");
    var fills =
        _childElements(element).map((x) => _parseShape(x, fill)).toList();
    return Vector(name: name, fill: fill, viewBox: viewBox, fills: fills);
  }

  ViewBox _parseViewBox(String value) {
    var split = value.split(" ").where((v) => !v.isEmpty).toList();
    if (split.length > 3) {
      return ViewBox(
        x: double.parse(split[0]),
        y: double.parse(split[1]),
        width: double.parse(split[2]),
        height: double.parse(split[3]),
      );
    }

    if (split.length > 1) {
      return ViewBox(
          x: 0.0,
          y: 0.0,
          width: double.parse(split[2]),
          height: double.parse(split[3]));
    }

    return null;
  }

  Shape _parseShape(xml.XmlElement element, Brush defaultFill) {
    var fill = _parseBrush(element.getAttribute("fill")) ?? defaultFill;

    if (element.name.toString() == "path") {
      var data = element.getAttribute("d");
      assert(data != null, "data ('d') must be precised for all paths");
      return Path(fill: fill, data: data);
    } else if (element.name.toString() == "rect") {
      var x = double.parse(element.getAttribute("x") ?? "0.0");
      var y = double.parse(element.getAttribute("y") ?? "0.0");
      var w = double.parse(element.getAttribute("width") ?? "0.0");
      var h = double.parse(element.getAttribute("height") ?? "0.0");
      return Rectangle(fill: fill, x: x, y: y, width: w, height: h);
    } else if (element.name.toString() == "circle") {
      var cx = double.parse(element.getAttribute("cx") ?? "0.0");
      var cy = double.parse(element.getAttribute("cy") ?? "0.0");
      var radius = double.parse(element.getAttribute("r") ?? "0.0");
      return Circle(fill: fill, centerX: cx, centerY: cy, radius: radius);
    }

    return null;
  }

  Brush _parseBrush(String value) {
    if (value != null && value.isNotEmpty) {
      if (value.startsWith("#")) {
        return Color(_parseColor(value));
      }
    }
    return null;
  }

  int _parseColor(String v) {
    if (v.startsWith("#")) {
      v = v.substring(1);
    }

    if (v.length > 8) {
      v = v.substring(0, 8);
    } else if (v.length > 5) {
      v = "FF" + v.substring(0, 6);
      ;
    } else if (v.length > 2) {
      final r = v[0];
      final g = v[1];
      final b = v[2];
      v = "FF$r$r$g$g$b$b";
    } else if (v.length > 0) {
      final r = v[0];
      v = "FF$r$r$r$r$r$r";
    } else {
      v = "FF000000";
    }

    return int.parse(v, radix: 16);
  }
}
