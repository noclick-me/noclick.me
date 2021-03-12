import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show MockPlatformInterfaceMixin;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart'
    show UrlLauncherPlatform;

import 'package:noclick_me/launch_url.dart';

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

void main() {
  group('launchUrl()', () {
    // Mock the url_launcher service
    final mockLauncher = MockUrlLauncher();
    final oldInstance = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = mockLauncher;

    setUp(() => reset(mockLauncher));

    tearDownAll(() => UrlLauncherPlatform.instance = oldInstance);

    const mockUrl = 'https://example.com/some/url';

    const canLaunchError = "Don't know how to open this URL type";

    Widget createTestWidget() => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                child: const Text('LAUNCH'),
                onPressed: () => launchUrl(mockUrl, context),
              ),
            ),
          ),
        );

    testWidgets('succeeds if canLaunch()', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      final buttonFinder = find.text('LAUNCH');
      expect(buttonFinder, findsOneWidget);

      logInvocations([mockLauncher]);
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
    });

    testWidgets('errors if !canLaunch()', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      final buttonFinder = find.text('LAUNCH');
      expect(buttonFinder, findsOneWidget);

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
      // A SnackBar should be shown
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(canLaunchError), findsOneWidget);
      await tester.pump(Duration(seconds: 3)); // Default duration is 4
      await tester.pumpAndSettle();
    });

    testWidgets('errors if launch() returns false',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      final buttonFinder = find.text('LAUNCH');
      expect(buttonFinder, findsOneWidget);

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
      // A SnackBar should be shown
      await tester.pump(Duration(seconds: 1));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(canLaunchError), findsOneWidget);
      await tester.pump(Duration(seconds: 3)); // Default duration is 4
      await tester.pumpAndSettle();
    });

    testWidgets('errors if launch() throws', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      final buttonFinder = find.text('LAUNCH');
      expect(buttonFinder, findsOneWidget);

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
    });
  });
}
