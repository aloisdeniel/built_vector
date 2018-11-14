import 'package:built_vector/model.dart';
import 'package:xml/xml.dart' as xml;

class AssetsParser {
  AssetsParser();

  Assets parse(String content) {
    if (content != null && content.isNotEmpty) {
      var document = xml.parse(content);
      var rootElement = document.rootElement;

      if (rootElement?.name.toString() == 'assets') {
        var name = rootElement.getAttribute("name");
        assert(name != null, "a name must be precised for assets");
        var vectors = rootElement.findElements('vector').map(_parseVector).toList();
        return Assets(name, vectors);
      }
    }

    return null;
  }

  Vector _parseVector(xml.XmlElement element) {
    var name = element.getAttribute("name");
    var fill = _parseBrush(element.getAttribute("fill")) ?? Color(0xFF000000);
    var viewBox = _parseViewBox(element.getAttribute("viewBox"));
    assert(name != null, "a name must be precised for each vector");
    assert(viewBox != null, "a viewBox must be precised for each vector");
    var fills = element.children.where((x) => x is xml.XmlElement).map((x) => x as xml.XmlElement).map((x) => _parseShape(x, fill)).toList();
    return Vector(name, fill, viewBox, fills);
  }

  ViewBox _parseViewBox(String value) {
    var split = value.split(" ").where((v) => !v.isEmpty).toList();
    if(split.length > 3) {
      return ViewBox(double.parse(split[0]), double.parse(split[1]), double.parse(split[2]), double.parse(split[3]));
    }

    if(split.length > 1) {
      return ViewBox(0.0, 0.0, double.parse(split[2]), double.parse(split[3]));
    }

    return null;
  }

  Shape _parseShape(xml.XmlElement element, Brush defaultFill) {
    var fill = _parseBrush(element.getAttribute("fill")) ?? defaultFill;

    if(element.name.toString() == "path") {
      var data = element.getAttribute("d");
      assert(data != null, "data ('d') must be precised for all paths");
      return Path(fill, data);
    }
    else if(element.name.toString() == "rect") {
      var x = double.parse(element.getAttribute("x") ?? "0.0");
      var y = double.parse(element.getAttribute("y") ?? "0.0");
      var w = double.parse(element.getAttribute("width") ?? "0.0");
      var h = double.parse(element.getAttribute("height") ?? "0.0");
      return Rectangle(fill, x, y, w, h);
    }
    else if(element.name.toString() == "circle") {
      var cx = double.parse(element.getAttribute("cx") ?? "0.0");
      var cy = double.parse(element.getAttribute("cy") ?? "0.0");
      var radius = double.parse(element.getAttribute("r") ?? "0.0");
      return Circle(fill, cx, cy, radius);
    }

    return null;
  }
  
  Brush _parseBrush(String value) {
    if(value != null && value.isNotEmpty) {
      if(value.startsWith("#")) {
          return Color(_parseColor(value));

      }
    }
    return null;
  }
  
  int _parseColor(String v) {
    if(v.startsWith("#")) {
      v = v.substring(1);
    }
        
    if(v.length > 8) {
      v = v.substring(0, 8);
    }
    else if(v.length > 5) {
      v = "FF" + v.substring(0, 6);;
    }
    else if(v.length > 2) {
      final r = v[0];
      final g = v[1];
      final b = v[2];
      v = "FF$r$r$g$g$b$b";
    }
    else if(v.length > 0) {
      final r = v[0];
      v = "FF$r$r$r$r$r$r";
    }
    else {
      v = "FF000000";
    }

    return int.parse(v, radix: 16);
  }
}
