import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:noclick_me/screenutil_builder.dart';
import 'package:noclick_me/url_form.dart';

void main() {
  group('UrlForm', () {
    const errorMsg = 'Please enter a valid http/https internet URL';

    Widget urlForm;

    setUp(() {
      urlForm = MaterialApp(
        home: Material(
          child: screenutilBuilder(
            child: UrlForm(),
          ),
        ),
      );
    });

    testWidgets('have all important widgets', (WidgetTester tester) async {
      await tester.pumpWidget(urlForm);
      final expandButtonFinder = find.byType(FlatButton);
      final urlFieldFinder = find.byType(TextFormField);

      expect(expandButtonFinder, findsOneWidget);
      expect(find.text('Expand'), findsOneWidget);
      expect(urlFieldFinder, findsOneWidget);
      expect(find.text('URL to expand'), findsOneWidget);
      expect(find.text(errorMsg), findsNothing);
    });

    group('gets an error when', () {
      testWidgets('tapping on button without input',
          (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final expandButton = find.byType(FlatButton);

        await tester.tap(expandButton);
        await tester.pumpAndSettle();

        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('pressing ENTER on empty field', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is a word', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final expandButton = find.byType(FlatButton);
        final urlField = find.byType(TextFormField);

        // Enter text auto-validates, so we should get an error as soon as we
        // start typing
        await tester.enterText(urlField, 'a');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);

        // Writing more text and being done with the input should also gives the
        // error
        await tester.enterText(urlField, 'invalid');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);

        // Tapping on the button too
        await tester.tap(expandButton);
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL starts with .', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, '.invalid');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL ends with .', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'invalid.');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is an invalid URI with schema',
          (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'http!://invalid*');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is a path (no domain)', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'invalid/bad/url');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL schema is not http(s)', (WidgetTester tester) async {
        await tester.pumpWidget(urlForm);
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'ftp://invalid.com/bad/url');
        await tester.pumpAndSettle();
        expect(find.text('Only http/https URLs are supported'), findsOneWidget);
      });
    });
  });
}
