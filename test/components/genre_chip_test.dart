import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:trailers/components/genre_chip.dart';

void main() {
  testWidgets('GenreChip should display a name', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: GenreChip(name: 'Hello World!')));

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
