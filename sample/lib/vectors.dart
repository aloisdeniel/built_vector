import 'package:flutter/widgets.dart';

typedef void Paint(Canvas canvas, Size size, {Color fill});

class Vector extends StatelessWidget {
  final Paint _paint;
  final Color _fill;
  Vector(this._paint, { Color fill: null}) : this._fill = fill;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _VectorPainter(this._paint, this._fill),);
  }
}

class _VectorPainter extends CustomPainter {
  final Paint _paint;
  final Color _fill;
  _VectorPainter(this._paint, this._fill);
  
  @override
  void paint(Canvas canvas, Size size) {
    this._paint(canvas, size, fill: _fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}