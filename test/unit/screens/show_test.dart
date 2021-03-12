import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;

import 'package:noclick_me/net.dart' show CreateUrlResponse, RateLimitInfo;
import 'package:noclick_me/screens/show.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('ShowUrlScreen', () {
    const mockUrl =
        'https://noclick.me/mock/url/asdfghjklqwertyuiopzxcvbnm_-.1234567890';
    final mockNavigatorObserver = MockNavigatorObserver();

    final showUrlScreenApp = MaterialApp(
      navigatorObservers: [mockNavigatorObserver],
      home: screenutilBuilder(
        child: ShowUrlScreen(const CreateUrlResponse(url: mockUrl)),
      ),
    );

    setUp(() => reset(mockNavigatorObserver));

    test('Constructor asserts on null response', () {
      expect(() => ShowUrlScreen(null), throwsAssertionError);
    });

    testWidgets('shows the URL (and only the URL if there is no rate limit',
        (WidgetTester tester) async {
      await tester.pumpWidget(showUrlScreenApp);
      expect(find.text(mockUrl.replaceAll('-', '\u2011')), findsOneWidget);
      expect(find.byType(RateLimitMessage), findsNothing);
      verifyNever(mockNavigatorObserver.didPop(any, any));
    });

    testWidgets('shows the URL and rate limit information if present',
        (WidgetTester tester) async {
      final showUrlScreenApp = MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        home: screenutilBuilder(
          child: ShowUrlScreen(
            const CreateUrlResponse(
                url: mockUrl,
                rateLimit: RateLimitInfo(
                  limit: 10,
                  remaining: 4,
                  reset: Duration(seconds: 34),
                )),
          ),
        ),
      );
      await tester.pumpWidget(showUrlScreenApp);
      expect(find.text(mockUrl.replaceAll('-', '\u2011')), findsOneWidget);
      verifyNever(mockNavigatorObserver.didPop(any, any));
    });

    testWidgets('COPY copies the URL to the clipboard',
        (WidgetTester tester) async {
      // Mock the clipboard service
      var clipboardData = <String, dynamic>{
        'text': null,
      };
      Future<dynamic> handler(MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Clipboard.getData':
            return clipboardData;
          case 'Clipboard.setData':
            clipboardData = methodCall.arguments as Map<String, dynamic>;
            break;
        }
      }

      SystemChannels.platform.setMockMethodCallHandler(handler);
      addTearDown(() => SystemChannels.platform.setMockMethodCallHandler(null));

      await tester.pumpWidget(showUrlScreenApp);
      final copyButtonFinder = find.text('COPY');
      expect(copyButtonFinder, findsOneWidget);

      await tester.tap(copyButtonFinder);
      await tester.pump();
      expect(clipboardData['text'], mockUrl);
      verifyNever(mockNavigatorObserver.didPop(any, any));
    });

    testWidgets('NEW LINK goes to the previous screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(showUrlScreenApp);
      final newLinkButtonFinder = find.text('NEW LINK');
      expect(newLinkButtonFinder, findsOneWidget);

      await tester.tap(newLinkButtonFinder);
      await tester.pump();
      verify(mockNavigatorObserver.didPop(any, any)).called(1);
    });
  });
}
