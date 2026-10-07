import 'dart:math' as math;
import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

typedef OcrPiece = ({String text, Rect box});

/// Rebuilds visual rows from OCR pieces.
///
/// ML Kit often returns a two-column receipt as the whole label column and then
/// the whole value column ("TOTAL" ... then "607.62", "638"), which separates a
/// label from its amount. Grouping by vertical position and joining left to
/// right restores lines like "TOTAL Rs.638".
String rowsFromPieces(List<OcrPiece> pieces) {
  final items = pieces.where((p) => p.text.trim().isNotEmpty && p.box.height > 0).toList();
  if (items.isEmpty) return '';

  final heights = items.map((p) => p.box.height).toList()..sort();
  final medianH = heights[heights.length ~/ 2];
  final tolerance = medianH * 0.6;

  items.sort((a, b) => a.box.center.dy.compareTo(b.box.center.dy));
  final rows = <List<OcrPiece>>[];
  var rowY = 0.0;
  for (final p in items) {
    if (rows.isNotEmpty && (p.box.center.dy - rowY).abs() <= tolerance) {
      rows.last.add(p);
      // Track the row's running centre so slightly tilted photos still group.
      rowY = rows.last.map((e) => e.box.center.dy).reduce((a, b) => a + b) / rows.last.length;
    } else {
      rows.add([p]);
      rowY = p.box.center.dy;
    }
  }

  return rows.map((row) {
    row.sort((a, b) => a.box.left.compareTo(b.box.left));
    return row.map((p) => p.text.trim().replaceAll('\n', ' ')).join(' ');
  }).join('\n');
}

typedef OcrQuad = ({String text, List<Offset> corners});

/// Rebuilds rows from words given as four corner points (text-frame order:
/// top-left, top-right, bottom-right, bottom-left).
///
/// Photos are often stored rotated (EXIF), so ML Kit reports positions in a
/// frame where text may run sideways or tilted. The corner points show the real
/// text direction, so everything is rotated upright first.
String rowsFromQuads(List<OcrQuad> quads) {
  final valid = quads.where((q) => q.text.trim().isNotEmpty && q.corners.length == 4).toList();
  if (valid.isEmpty) return '';

  // Average text direction (unit vectors, so angles wrap correctly).
  var cx = 0.0, cy = 0.0;
  for (final q in valid) {
    final d = q.corners[1] - q.corners[0];
    final len = d.distance;
    if (len == 0) continue;
    cx += d.dx / len;
    cy += d.dy / len;
  }
  final theta = math.atan2(cy, cx);
  final cosT = math.cos(theta), sinT = math.sin(theta);

  final pieces = <OcrPiece>[];
  for (final q in valid) {
    final c = q.corners;
    final centre = Offset(
      (c[0].dx + c[1].dx + c[2].dx + c[3].dx) / 4,
      (c[0].dy + c[1].dy + c[2].dy + c[3].dy) / 4,
    );
    // Rotate so the text direction becomes the x axis.
    final x = centre.dx * cosT + centre.dy * sinT;
    final y = -centre.dx * sinT + centre.dy * cosT;
    final w = (c[1] - c[0]).distance;
    final h = (c[3] - c[0]).distance;
    if (h <= 0) continue;
    pieces.add((text: q.text, box: Rect.fromCenter(center: Offset(x, y), width: w, height: h)));
  }
  return rowsFromPieces(pieces);
}

/// Row-ordered text for a ML Kit result, falling back to its own text.
/// Uses individual words: ML Kit's "lines" can be whole merged columns.
String rowsFromRecognizedText(RecognizedText result) {
  final quads = <OcrQuad>[];
  for (final block in result.blocks) {
    for (final line in block.lines) {
      final elements = line.elements.isNotEmpty ? line.elements : null;
      if (elements != null) {
        for (final el in elements) {
          quads.add((text: el.text, corners: _corners(el.cornerPoints, el.boundingBox)));
        }
      } else {
        quads.add((text: line.text, corners: _corners(line.cornerPoints, line.boundingBox)));
      }
    }
  }
  final rows = rowsFromQuads(quads);
  return rows.isEmpty ? result.text : rows;
}

List<Offset> _corners(List<dynamic> points, Rect box) {
  if (points.length == 4) {
    return [for (final p in points) Offset((p.x as num).toDouble(), (p.y as num).toDouble())];
  }
  return [box.topLeft, box.topRight, box.bottomRight, box.bottomLeft];
}
