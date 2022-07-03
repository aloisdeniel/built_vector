import 'package:built_vector/model.dart';
import 'package:xml/xml.dart';

Iterable<XmlElement> _childElements(XmlElement element) =>
  element.children.where((x) => x is XmlElement).cast<XmlElement>();

class AssetsParser {
  AssetsParser();

  Assets parse(String? content) {
    if (content == null || content.isEmpty) {
      throw new Exception('Content must not be empty');
    }

    var document = XmlDocument.parse(content);
    var rootElement = document.rootElement;
    if (rootElement.name.toString() != 'assets') {
      throw new Exception('Root element must be assets');
    }

    var name = rootElement.getAttribute("name");
    assert(name != null, "a name must be precised for assets");
    var definitions = rootElement
        .findElements('defs')
        .expand((x) => _childElements(x).map(_parseDefinition));

    var vectors =
        rootElement.findElements('vector').map(_parseVector).toList();
    return Assets(name: name!, vectors: vectors, definitions: definitions.toList());
  }

  Definition _parseDefinition(XmlElement element) {
    var id = element.getAttribute("id");
    if (id == null) {
      throw Exception('An id must be precised for definitions');
    }

    if (element.name.toString() == "linearGradient") {
      var x1 = element.getAttribute("x1") ?? "0%";
      var x2 = element.getAttribute("x2") ?? "100%";
      var y1 = element.getAttribute("y1") ?? "0%";
      var y2 = element.getAttribute("y2") ?? "0%";
      return LinearGradient(
        id: id,
        x1: _parseLength(x1),
        x2: _parseLength(x2),
        y1: _parseLength(y1),
        y2: _parseLength(y2),
        stops: element.findAllElements("stop").map(_parseGradientStop).toList()
      );
    }

    if (element.name.toString() == "radialGradient") {
      var cx = element.getAttribute("cx") ?? "50%";
      var cy = element.getAttribute("x2") ?? "50%";
      var r = element.getAttribute("r") ?? "50%";
      return RadialGradient(
        id: id,
        cx: _parseLength(cx),
        cy: _parseLength(cy),
        r: _parseLength(r),
        stops: element.findAllElements("stop").map(_parseGradientStop).toList()
      );
    }

    throw UnimplementedError();
  }

  GradientStop _parseGradientStop(XmlElement element) {
    var color = element.getAttribute("stop-color") ?? "#000000";
    var offset = element.getAttribute("offset") ?? "0.0";
    var opacity = element.getAttribute("stop-opacity") ?? "1.0";
    return GradientStop(
      color: Color(_parseColor(color)),
      offset: _parseAmount(offset),
      opacity: double.parse(opacity)
    );
  }

  Length _parseLength(String value) {
    if (value == null) return Length.amount(0.0);
    value = value.trim();
    if (value.endsWith("%")) {
      return Length.amount(
          double.parse(value.substring(0, value.length - 1)).clamp(0.0, 100.0) /
              100.0);
    }
    return Length.absolute(double.parse(value));
  }

  double _parseAmount(String value) {
    if (value == null) return 0.0;
    value = value.trim();
    if (value.endsWith("%")) {
      return double.parse(value.substring(0, value.length - 1))
              .clamp(0.0, 100.0) /
          100.0;
    }
    return double.parse(value).clamp(0.0, 1.0);
  }

  Vector _parseVector(XmlElement element) {
    var name = element.getAttribute("name");
    var fill = _parseBrush(element.getAttribute("fill")) ?? Color(0xFF000000);
    var viewBox = _parseViewBox(element.getAttribute("viewBox"));

    if (name == null) {
      throw Exception('A name must be precised for each vector');
    }

    var fills = _childElements(element)
      .map((x) => _parseShape(x, fill))
      .expand<Shape>((element) => element != null ? [element] : [])
      .toList();
    return Vector(name: name, fill: fill, viewBox: viewBox, fills: fills);
  }

  ViewBox _parseViewBox(String? value) {
    if (value == null) {
      throw Exception('Viewbox cannot be empty');
    }

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
    throw Exception('A viewbox must be precised for each vector');
  }

  Shape? _parseShape(XmlElement element, Brush defaultFill) {
    var fill = _parseBrush(element.getAttribute("fill")) ?? defaultFill;

    if (element.name.toString() == "path") {
      var data = element.getAttribute("d");
      if (data == null) {
        throw Exception("Data ('d') must be precised for all paths");
      }
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

  Brush? _parseBrush(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!value.startsWith("#")) {
      return null;
    }
    return Color(_parseColor(value));
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
