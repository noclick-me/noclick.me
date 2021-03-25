import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';

import 'package:noclick_me/markdown_asset.dart';

void main() {
  group('MarkdownAsset', () {
    test('constructor asserts on bad arguments', () {
      expect(() => MarkdownAsset(location: null), throwsAssertionError);
    });

    testWidgets('invalid asset shows error', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MarkdownAsset(location: 'invalid.md'),
        ),
      );
      // First it shows the indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After the asset fails to load, an error should be shown
      await tester.pumpAndSettle();
      expect(
          find.text('Error: Unable to load asset: invalid.md'), findsOneWidget);
    });
  });
}
