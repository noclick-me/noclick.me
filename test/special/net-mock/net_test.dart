import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:noclick_me/net.dart';

void main() {
  group('NoClickService', () {
    test('createUrl()', () async {
      final url = Uri.parse('https://example.com');

      expect(
        await NoClickService(httpClient: http.Client()).createUrl(url),
        NoClickService.MOCK_RESPONSE,
      );
    });
  });
}
