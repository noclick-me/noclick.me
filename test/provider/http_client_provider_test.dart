import 'package:flutter/widgets.dart' hide HttpClientProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart' show MockClient;

import 'package:noclick_me/provider/http_client_provider.dart';

void main() {
  group('HttpClientProvider', () {
    final mockClient = MockClient((r) => null);

    testWidgets('constructor asserts on null required parameters',
        (WidgetTester tester) async {
      expect(
        () => HttpClientProvider(client: null, child: Container()),
        throwsAssertionError,
      );
      expect(
        () => HttpClientProvider(child: null, client: mockClient),
        throwsAssertionError,
      );
      expect(
        () => HttpClientProvider(child: null, client: null),
        throwsAssertionError,
      );
    });

    testWidgets('child is built when pumped', (WidgetTester tester) async {
      final key = GlobalKey(debugLabel: 'childKey');
      final provider = HttpClientProvider(
        client: mockClient,
        child: Container(key: key),
      );

      await tester.pumpWidget(provider);
      expect(find.byKey(key), findsOneWidget);
      expect(provider.client, same(mockClient));
    });

    testWidgets('child can find the client', (WidgetTester tester) async {
      final provider = HttpClientProvider(
        client: mockClient,
        child: Builder(builder: (context) {
          expect(HttpClientProvider.of(context).client, same(mockClient));
          return Container();
        }),
      );

      await tester.pumpWidget(provider);
    });
  });
}
