import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' show IOClient;
import 'package:http/testing.dart' show MockClient;

import 'package:noclick_me/net.dart';

void main() {
  group('NoClickService', () {
    test('constructors', () {
      final service = NoClickService();
      expect(service.serverUrl, Uri.parse(NoClickService.SERVER_URL_DEFAULT));
      expect(service.httpClient, isA<IOClient>());
    });

    test('createUrl()', () async {
      final url = Uri.parse('https://example.com');
      final noclickUrl = 'https://some.long/url';

      var client = MockClient(
        (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200),
      );
      expect(await NoClickService(client: client).createUrl(url), noclickUrl);

      client = MockClient(
        (req) async => http.Response('BAD', 400),
      );
      expect(await NoClickService(client: client).createUrl(url),
          'NOT OK: status=400');
    });
  });
}
