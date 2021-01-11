import 'dart:async' show FutureOr;

import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show Response;
import 'package:http/testing.dart' show MockClient, MockClientHandler;
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show MockPlatformInterfaceMixin;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'
    show UrlLauncherPlatform;

import 'package:noclick_me/provider/http_client_provider.dart'
    show HttpClientProvider;
import 'package:noclick_me/screens/show.dart' show ShowUrlScreen;
import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;
import 'package:noclick_me/url_form.dart' show UrlForm;

import 'package:noclick_me/screens/home.dart';

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('Home', () {
    final mockNavigatorObserver = MockNavigatorObserver();

    Widget createHomeScreen(
            {MockClientHandler mockClientHandler,
            FutureOr<void> Function(String url) onSuccess}) =>
        MaterialApp(
          navigatorObservers: [mockNavigatorObserver],
          home: HttpClientProvider(
            client: MockClient(mockClientHandler ?? (r) => null),
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
  });
}
