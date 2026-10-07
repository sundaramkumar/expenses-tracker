import 'dart:ui';

import 'package:expenses_tracker/utils/ocr_rows.dart';
import 'package:expenses_tracker/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

OcrPiece p(String t, double x, double y) => (text: t, box: Rect.fromLTWH(x, y, 100, 30));

void main() {
  wordTests();
  rotationTests();
  // ML Kit returned the label column first, then the value column.
  final columnOrder = [
    p('Thank U Cafe-Surya Nagar', 200, 10),
    p('Date', 10, 60), p('28 Sept 2026, 07:34 pm', 500, 62),
    p('Subtotal', 10, 400), p('CGST 2.5%', 10, 440), p('SGST 2.5%', 10, 480), p('TOTAL', 10, 540),
    p('607.62', 600, 402), p('15.19', 600, 441), p('15.19', 600, 479), p('Rs.638', 600, 541),
  ];

  test('rows rejoin each label with its amount', () {
    final text = rowsFromPieces(columnOrder);
    expect(text, contains('TOTAL Rs.638'));
    expect(text, contains('Subtotal 607.62'));
    expect(text, contains('Date 28 Sept 2026, 07:34 pm'));
  });

  test('parser takes the total, not the subtotal, on column-ordered OCR', () {
    final r = ReceiptParser.parse(rowsFromPieces(columnOrder));
    expect(r.amount, 638.0);
    expect(r.date, DateTime(2026, 9, 28));
  });

  test('without row rebuilding the old failure reproduces', () {
    final raw = columnOrder.map((e) => e.text).join('\n');
    expect(ReceiptParser.parse(raw).amount, isNot(638.0));
  });
}

void wordTests() {
  // Word-level boxes as ML Kit gives them; the merged "lines" are irrelevant.
  OcrPiece w(String t, double x, double y, {double h = 30}) => (text: t, box: Rect.fromLTWH(x, y, 80, h));
  test('word boxes rebuild TOTAL Rs.638 even when columns were merged', () {
    final words = [
      w('Subtotal', 10, 400), w('607.62', 600, 402),
      w('CGST', 10, 440), w('2.5%', 100, 441), w('15.19', 600, 441),
      w('SGST', 10, 480), w('2.5%', 100, 481), w('15.19', 600, 479),
      w('TOTAL', 10, 530, h: 60), w('Rs.638', 600, 532, h: 60),
    ];
    final text = rowsFromPieces(words);
    expect(text, contains('TOTAL Rs.638'));
    expect(ReceiptParser.parse(text).amount, 638.0);
  });
}

void rotationTests() {
  // Words as upright boxes, then rotated 90 degrees the way a sideways-stored photo reports them.
  List<Offset> quad(double x, double y, {double w = 80, double h = 30, int rot = 0}) {
    var pts = [Offset(x, y), Offset(x + w, y), Offset(x + w, y + h), Offset(x, y + h)];
    for (var i = 0; i < rot; i++) {
      // 90 degrees clockwise in image coordinates, keeping corner order text-relative.
      pts = pts.map((p) => Offset(-p.dy + 1000, p.dx)).toList();
    }
    return pts;
  }

  for (final rot in [0, 1, 2, 3]) {
    test('rows rebuild correctly when the photo frame is rotated by $rot x 90 degrees', () {
      OcrQuad w(String t, double x, double y, {double h = 30}) =>
          (text: t, corners: quad(x, y, h: h, rot: rot));
      final words = [
        w('Date', 10, 60), w('28', 400, 62), w('Sept', 480, 62), w('2026,', 560, 62),
        w('Subtotal', 10, 400), w('607.62', 600, 402),
        w('CGST', 10, 440), w('2.5%', 100, 441), w('15.19', 600, 441),
        w('SGST', 10, 480), w('2.5%', 100, 481), w('15.19', 600, 479),
        w('TOTAL', 10, 530, h: 60), w('Rs.638', 600, 532, h: 60),
        w('Thank', 10, 700), w('U', 100, 700), w('Cafe', 140, 701),
      ];
      final text = rowsFromQuads(words);
      expect(text, contains('Subtotal 607.62'));
      expect(text, contains('TOTAL Rs.638'));
      expect(text, contains('Date 28 Sept 2026,'));
      expect(ReceiptParser.parse(text).amount, 638.0);
    });
  }
}
