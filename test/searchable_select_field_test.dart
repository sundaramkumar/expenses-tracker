import 'package:expenses_tracker/widgets/searchable_select_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('typing filters options and selecting returns the item', (tester) async {
    int? selected;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SearchableSelectField(
            label: 'Category',
            icon: Icons.category,
            options: const [
              (id: 1, name: 'Business'),
              (id: 2, name: 'Food'),
              (id: 3, name: 'Gifts'),
              (id: 4, name: 'Insurance'),
              (id: 5, name: 'Footwear'),
            ],
            value: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
      ),
    ));

    await tester.tap(find.byType(SearchableSelectField));
    await tester.pumpAndSettle();
    expect(find.text('Business'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'fo');
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Footwear'), findsOneWidget);
    expect(find.text('Business'), findsNothing);
    expect(find.text('Gifts'), findsNothing);

    await tester.enterText(find.byType(TextField), 'food');
    await tester.pumpAndSettle();
    expect(find.text('Footwear'), findsNothing);

    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(selected, 2);
    expect(find.text('Food'), findsOneWidget);
  });
}
