import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_linkify/flutter_linkify.dart' show SelectableLinkify;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show MockPlatformInterfaceMixin;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'
    show UrlLauncherPlatform;

import 'package:noclick_me/screenutil_builder.dart' show screenutilBuilder;

import 'package:noclick_me/net.dart' show CreateUrlResponse, RateLimitInfo;
import 'package:noclick_me/screens/show.dart';

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

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

    void testOpenUrl(Finder buttonFinder) {
      testWidgets('OPEN launches the URL or shows an error',
          (WidgetTester tester) async {
        // Mock the url_launcher service
        final mockLauncher = MockUrlLauncher();
        final oldInstance = UrlLauncherPlatform.instance;
        UrlLauncherPlatform.instance = mockLauncher;
        addTearDown(() => UrlLauncherPlatform.instance = oldInstance);

        await tester.pumpWidget(showUrlScreenApp);
        expect(buttonFinder, findsOneWidget);

        // Success
        when(mockLauncher.canLaunch(mockUrl)).thenAnswer((_) async => true);
        when(mockLauncher.launch(
          mockUrl,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).thenAnswer((_) async => true);
        await tester.tap(buttonFinder);
        await tester.pump();
        verify(mockLauncher.canLaunch(mockUrl)).called(1);
        verify(mockLauncher.launch(
          mockUrl,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).called(1);
        verifyNoMoreInteractions(mockLauncher);
        // No SnackBar should be shown
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(SnackBar), findsNothing);

        // Error if canLaunch is false
        const canLaunchError = "Don't know how to open this URL type";
        clearInteractions(mockLauncher);
        when(mockLauncher.canLaunch(mockUrl)).thenAnswer((_) async => false);
        await tester.tap(buttonFinder);
        await tester.pump();
        verify(mockLauncher.canLaunch(mockUrl)).called(1);
        verifyNever(mockLauncher.launch(
          any,
          useWebView: anyNamed('useWebView'),
          enableJavaScript: anyNamed('enableJavaScript'),
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        ));
        verifyNoMoreInteractions(mockLauncher);
        // No SnackBar should be shown
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(canLaunchError), findsOneWidget);
        await tester.pump(Duration(seconds: 3)); // Default duration is 4
        await tester.pumpAndSettle();

        // Error if launch returns false
        clearInteractions(mockLauncher);
        when(mockLauncher.canLaunch(mockUrl)).thenAnswer((_) async => true);
        when(mockLauncher.launch(
          mockUrl,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).thenAnswer((_) async => false);
        await tester.tap(buttonFinder);
        await tester.pump();
        verify(mockLauncher.canLaunch(mockUrl)).called(1);
        verify(mockLauncher.launch(
          any,
          useWebView: anyNamed('useWebView'),
          enableJavaScript: anyNamed('enableJavaScript'),
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).called(1);
        verifyNoMoreInteractions(mockLauncher);
        // No SnackBar should be shown
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(canLaunchError), findsOneWidget);
        await tester.pump(Duration(seconds: 3)); // Default duration is 4
        await tester.pumpAndSettle();

        // Error if launch throws
        clearInteractions(mockLauncher);
        when(mockLauncher.canLaunch(mockUrl)).thenAnswer((_) async => true);
        when(mockLauncher.launch(
          mockUrl,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).thenAnswer((_) async => throw Exception('LaunchException'));
        await tester.tap(buttonFinder);
        await tester.pump();
        verify(mockLauncher.canLaunch(mockUrl)).called(1);
        verify(mockLauncher.launch(
          any,
          useWebView: anyNamed('useWebView'),
          enableJavaScript: anyNamed('enableJavaScript'),
          enableDomStorage: anyNamed('enableDomStorage'),
          useSafariVC: anyNamed('useSafariVC'),
          headers: anyNamed('headers'),
          universalLinksOnly: anyNamed('universalLinksOnly'),
          webOnlyWindowName: anyNamed('webOnlyWindowName'),
        )).called(1);
        verifyNoMoreInteractions(mockLauncher);
        // No SnackBar should be shown
        await tester.pump(Duration(seconds: 1));
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text("Can't open URL: Exception: LaunchException"),
            findsOneWidget);
        await tester.pump(Duration(seconds: 3)); // Default duration is 4
        await tester.pumpAndSettle();
        verifyNever(mockNavigatorObserver.didPop(any, any));
      });
    }

    testOpenUrl(find.text('OPEN'));
    testOpenUrl(find.byType(SelectableLinkify));

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
