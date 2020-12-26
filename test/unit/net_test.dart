import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' show MockClient;

import 'package:noclick_me/net.dart';

void main() {
  group('NoClickService', () {
    test('constructors', () {
      final client = MockClient((req) => null);
      final service = NoClickService(httpClient: client);
      expect(service.serverUrl, Uri.parse(NoClickService.SERVER_URL_DEFAULT));
      expect(service.httpClient, same(client));
      expect(() => NoClickService(httpClient: null), throwsAssertionError);
    });

    test('createUrl()', () async {
      final url = Uri.parse('https://example.com');
      final noclickUrl = 'https://some.long/url';

      var client = MockClient(
        (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200),
      );
      expect(
          await NoClickService(httpClient: client).createUrl(url), noclickUrl);

      client = MockClient(
        (req) async => http.Response('BAD', 400),
      );
      expect(await NoClickService(httpClient: client).createUrl(url),
          'NOT OK: status=400');
    });
  });
}
