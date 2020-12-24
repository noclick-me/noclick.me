import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:meta/meta.dart' show required;
import 'package:http/http.dart' as http;

class NoClickService {
  static const SERVER_URL_DEFAULT = 'https://api.noclick.me';
  static const SERVER_URL_VAR_NAME = 'API_URL';

  final Uri _serverUrl;

  Uri get serverUrl => _serverUrl;

  final http.Client httpClient;

  NoClickService({@required this.httpClient, Uri serverUrl})
      : assert(httpClient != null),
        _serverUrl = serverUrl ??
            Uri.parse(const String.fromEnvironment(SERVER_URL_VAR_NAME,
                defaultValue: SERVER_URL_DEFAULT));

  Future<String> createUrl(Uri url) async {
    final response = await httpClient.post('$_serverUrl/url',
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'url': url.toString(),
        }));

    if (response.statusCode != 200) {
      return 'NOT OK: status=${response.statusCode}';
    }

    return jsonDecode(response.body)['noclick_url'].toString();
  }
}
