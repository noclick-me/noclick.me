import 'package:flutter_markdown/flutter_markdown.dart' show Markdown;
import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';

import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;

import 'package:noclick_me/screens/terms_and_conditions.dart';

void main() {
  group('Home', () {
    Widget createScreen() => MaterialApp(
          home: screenutilBuilder(
            child: TermsAndConditionsScreen(),
          ),
        );

    testWidgets('shows a progress indicator while loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(createScreen());
      expect(find.text('Terms and Conditions'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Markdown), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
