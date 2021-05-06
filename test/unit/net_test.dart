import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' show MockClient;

import 'package:noclick_me/net.dart';

void main() {
  group('NoClickService', () {
    test('constructors', () {
      final client = MockClient((req) => Future.value(null));
      final service = NoClickService(httpClient: client);
      expect(service.serverUrl, Uri.parse(NoClickService.SERVER_URL_DEFAULT));
      expect(service.httpClient, same(client));
    });

    test('toString()', () {
      final rateLimit =
          RateLimitInfo(limit: 1, remaining: 2, reset: Duration.zero);
      expect(rateLimit.toString(),
          'RateLimitInfo(limit: 1, remaining: 2, reset: 0:00:00.000000)');
      expect(
          CreateUrlResponse(url: 'https://example.com').toString(),
          'CreateUrlResponse(url: https://example.com, error: null, '
          'rateLimit: null)');
      expect(
          CreateUrlResponse.error('BAD!').toString(),
          'CreateUrlResponse(url: null, error: BAD!, '
          'rateLimit: null)');
      expect(
          CreateUrlResponse(url: 'https://example.com', rateLimit: rateLimit)
              .toString(),
          'CreateUrlResponse(url: https://example.com, error: null, '
          'rateLimit: RateLimitInfo(limit: 1, remaining: 2, '
          'reset: 0:00:00.000000))');
    });

    group('createUrl()', () {
      final url = Uri.parse('https://example.com');
      final noclickUrl = 'https://some.long/url';

      Map<String, String> limits({
        String? limit,
        String? remaining,
        String? reset,
      }) {
        final r = <String, String>{};
        if (limit != null) r['x-ratelimit-limit'] = limit;
        if (remaining != null) r['x-ratelimit-remaining'] = remaining;
        if (reset != null) r['x-ratelimit-reset'] = reset;
        return r;
      }

      test('OK, no ratelimit', () async {
        final client = MockClient(
          (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200),
        );
        final response =
            await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, noclickUrl);
        expect(response.error, isNull);
        expect(response.rateLimit, isNull);
      });

      test('BAD, no ratelimit', () async {
        final client = MockClient(
          (req) async => http.Response('BAD', 400),
        );
        final response =
            await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, isNull);
        expect(response.error, 'Unable to create new URL, status=400');
        expect(response.rateLimit, isNull);
      });

      test('OK, with ratelimit', () async {
        final client = MockClient(
          (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200,
              headers: limits(limit: '10', remaining: '123', reset: '10')),
        );
        final response =
            await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, noclickUrl);
        expect(response.error, isNull);
        final rateLimit = response.rateLimit!;
        expect(rateLimit.limit, 10);
        expect(rateLimit.remaining, 123);
        expect(rateLimit.reset, Duration(seconds: 10));
      });

      test('BAD, with ratelimit', () async {
        var client = MockClient(
          (req) async => http.Response('BAD', 400,
              headers: limits(limit: '10', remaining: '123', reset: '10')),
        );
        var response = await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, isNull);
        expect(response.error, 'Unable to create new URL, status=400');
        final rateLimit = response.rateLimit!;
        expect(rateLimit.limit, 10);
        expect(rateLimit.remaining, 123);
        expect(rateLimit.reset, Duration(seconds: 10));
      });

      test('OK, with missing ratelimit values', () async {
        final client = MockClient(
          (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200,
              headers: limits(limit: '10', reset: '10')),
        );
        final response =
            await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, noclickUrl);
        expect(response.error, isNull);
        expect(response.rateLimit, isNull);
      });

      test('OK, with wrong ratelimit values', () async {
        final client = MockClient(
          (req) async => http.Response('{"noclick_url": "$noclickUrl"}', 200,
              headers: limits(limit: '10', remaining: 'not many', reset: '10')),
        );
        final response =
            await NoClickService(httpClient: client).createUrl(url);
        expect(response.url, noclickUrl);
        expect(response.error, isNull);
        expect(response.rateLimit, isNull);
      });
    });
  });
}
