import 'dart:convert' show jsonDecode;
import 'dart:async' show FutureOr;

import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Request, Response;
import 'package:http/testing.dart' show MockClient, MockClientHandler;

import 'package:noclick_me/provider/http_client_provider.dart'
    show HttpClientProvider;
import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;

import 'package:noclick_me/url_form.dart';

void main() {
  group('UrlForm', () {
    const errorMsg = 'Please enter a valid http/https internet URL';

    Widget createForm(
            {MockClientHandler mockClientHandler,
            FutureOr<void> Function(String url) onSuccess}) =>
        MaterialApp(
          home: Scaffold(
            body: HttpClientProvider(
              client: MockClient(mockClientHandler ?? (r) => null),
              child: screenutilBuilder(
                child: UrlForm(onSuccess: onSuccess),
              ),
            ),
          ),
        );

    testWidgets('have all important widgets', (WidgetTester tester) async {
      await tester.pumpWidget(createForm());
      final expandButtonFinder = find.byType(TextButton);
      final urlFieldFinder = find.byType(TextFormField);

      expect(expandButtonFinder, findsOneWidget);
      expect(find.text('Expand'), findsOneWidget);
      expect(urlFieldFinder, findsOneWidget);
      expect(find.text('URL to expand'), findsOneWidget);
      expect(find.text(errorMsg), findsNothing);
    });

    group('errors when', () {
      testWidgets('tapping on button without input',
          (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final expandButton = find.byType(TextButton);

        await tester.tap(expandButton);
        await tester.pumpAndSettle();

        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('pressing ENTER on empty field', (WidgetTester tester) async {
        await tester.pumpWidget(createForm());

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is a word', (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final expandButton = find.byType(TextButton);
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
        await tester.pumpWidget(createForm());
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, '.invalid');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL ends with .', (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'invalid.');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is an invalid URI with schema',
          (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'http!://invalid*');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL is a path (no domain)', (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'invalid/bad/url');
        await tester.pumpAndSettle();
        expect(find.text(errorMsg), findsOneWidget);
      });

      testWidgets('the URL schema is not http(s)', (WidgetTester tester) async {
        await tester.pumpWidget(createForm());
        final urlField = find.byType(TextFormField);

        await tester.enterText(urlField, 'ftp://invalid.com/bad/url');
        await tester.pumpAndSettle();
        expect(find.text('Only http/https URLs are supported'), findsOneWidget);
      });

      testWidgets('server response is not 200 OK', (WidgetTester tester) async {
        String success_url;
        await tester.pumpWidget(createForm(
          mockClientHandler: (r) async => Response('BAD', 400),
          onSuccess: (url) => success_url = url,
        ));

        await tester.enterText(
          find.byType(TextFormField),
          'https://example.com',
        );

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(); // Wait for the new screen animation
        expect(success_url, 'NOT OK: status=400');
      });

      testWidgets('there is an unexpected exception in net',
          (WidgetTester tester) async {
        const exceptionText = 'Unexpected!Ex';
        await tester.pumpWidget(createForm(
          mockClientHandler: (r) async => throw Exception(exceptionText),
        ));

        await tester.enterText(
          find.byType(TextFormField),
          'https://example.com',
        );
        expect(find.byType(SnackBar), findsNothing);

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(); // Wait for the SnackBar in animation
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Could not retrieve the page: $exceptionText'),
            findsOneWidget);

        await tester.pump(Duration(seconds: 4)); // Default SnackBar duration
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
      }); // FIXME: I CAN'T FIND THE SNACKBAR with the error
    });

    group('succeeds', () {
      void testInputSucceeds(
          {@required String input, @required String output}) {
        Future<Response> createUrlHandler(Request r) async {
          final dynamic req = jsonDecode(r.body);
          final u = Uri.parse(req['url'].toString());
          final path = '${u.scheme}/${u.host}${u.path}/long';
          return Response('{"noclick_url": "https://noclick.me/$path"}', 200);
        }

        testWidgets('for $input', (WidgetTester tester) async {
          String success_url;
          await tester.pumpWidget(createForm(
            mockClientHandler: createUrlHandler,
            onSuccess: (url) => success_url = url,
          ));

          await tester.enterText(find.byType(TextFormField), input);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          expect(success_url, output);
        });
      }

      testInputSucceeds(
        input: 'example.com',
        output: 'https://noclick.me/https/example.com/long',
      );

      testInputSucceeds(
        input: '/example.com',
        output: 'https://noclick.me/https/example.com/long',
      );

      testInputSucceeds(
        input: '//example.com',
        output: 'https://noclick.me/https/example.com/long',
      );

      testInputSucceeds(
        input: 'example.com/with/path',
        output: 'https://noclick.me/https/example.com/with/path/long',
      );

      testInputSucceeds(
        input: '/example.com/with/path',
        output: 'https://noclick.me/https/example.com/with/path/long',
      );

      testInputSucceeds(
        input: '//example.com/with/path',
        output: 'https://noclick.me/https/example.com/with/path/long',
      );
    });
  });
}
