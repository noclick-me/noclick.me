import 'dart:async' show FutureOr;

import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:http/testing.dart' show MockClient, MockClientHandler;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:noclick_me/provider/http_client_provider.dart'
    show HttpClientProvider;
import 'package:noclick_me/screens/show.dart' show ShowUrlScreen;
import 'package:noclick_me/screens/privacy_policy.dart'
    show PrivacyPolicyScreen;
import 'package:noclick_me/screens/terms_and_conditions.dart'
    show TermsAndConditionsScreen;
import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;
import 'package:noclick_me/url_form.dart' show UrlForm;

import 'package:noclick_me/screens/home.dart';

import 'home_test.mocks.dart';

// TODO: remove returnNullOnMissingStub
@GenerateMocks([], customMocks: [
  MockSpec<NavigatorObserver>(returnNullOnMissingStub: true),
])
void main() {
  group('Home', () {
    final mockNavigatorObserver = MockNavigatorObserver();

    Widget createHomeScreen(
            {MockClientHandler? mockClientHandler,
            FutureOr<void> Function(String url)? onSuccess}) =>
        MaterialApp(
          navigatorObservers: [mockNavigatorObserver],
          home: HttpClientProvider(
            client:
                MockClient(mockClientHandler ?? ((r) => Future.value(null))),
            child: screenutilBuilder(
              child: Home(),
            ),
          ),
        );

    setUp(() => reset(mockNavigatorObserver));

    testWidgets('expands an URL successfully', (WidgetTester tester) async {
      const expandedUrl = 'https://test.api.noclick.me/some/fake/url';
      await tester.pumpWidget(createHomeScreen(
          mockClientHandler: (r) async =>
              Response('{"noclick_url": "$expandedUrl"}', 200)));
      final urlFormFinder = find.byType(UrlForm);
      final textFieldFinder = find.descendant(
        of: urlFormFinder,
        matching: find.byType(TextField),
      );
      final expandButtonFinder = find.descendant(
        of: urlFormFinder,
        matching: find.text('Expand'),
      );

      clearInteractions(mockNavigatorObserver);
      await tester.enterText(textFieldFinder, 'https://example.com');
      await tester.tap(expandButtonFinder);
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(ShowUrlScreen), findsOneWidget);
    });

    testWidgets('shows privacy policy screen', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      final privacyPolicyButton = find.text('Privacy Policy');

      clearInteractions(mockNavigatorObserver);
      await tester.tap(privacyPolicyButton);
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
    });

    testWidgets('shows terms and conditions screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      final privacyPolicyButton = find.text('Terms and Conditions');

      clearInteractions(mockNavigatorObserver);
      await tester.tap(privacyPolicyButton);
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(TermsAndConditionsScreen), findsOneWidget);
    });

    testWidgets('shows licenses screen', (WidgetTester tester) async {
      await tester.pumpWidget(createHomeScreen());
      final licensesButton = find.text('Licenses');

      clearInteractions(mockNavigatorObserver);
      await tester.tap(licensesButton);
      await tester.pumpAndSettle();
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(LicensePage), findsOneWidget);
    });
  });
}
