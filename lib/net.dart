import 'dart:convert' show jsonEncode, jsonDecode;
import 'dart:io' show X509Certificate, HttpClient;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' show IOClient;

class NoClickService {
  static const SERVER_URL_DEFAULT = 'https://api.noclick.me';
  static const SERVER_URL_VAR_NAME = 'API_URL';

  final Uri _serverUrl;

  http.Client _client;

  NoClickService({Uri serverUrl})
      : _serverUrl = serverUrl ??
            Uri.parse(const String.fromEnvironment(SERVER_URL_VAR_NAME,
                defaultValue: SERVER_URL_DEFAULT)) {
    // XXX: All this is a big hack to be able to connect to self-signed
    //      certificates (which opens the door to any other bad certificate, so
    //      this is really really a BAD THING (TM). It should only be enabled
    //      in debug or test builds or removed completely in the future, once
    //      a good and simple way to test is found.
    if (kIsWeb) {
      _client = http.Client();
    } else {
      final ioHttpClient = HttpClient();
      ioHttpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      _client = IOClient(ioHttpClient);
    }
  }

  Future<String> createUrl(Uri url) async {
    final response = await _client.post(_serverUrl,
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'url': url.toString(),
        }));

    if (response.statusCode != 200) {
      return 'NOT OK: statuc=${response.statusCode}';
    }

    return jsonDecode(response.body)['noclick_url'].toString();
  }
}
