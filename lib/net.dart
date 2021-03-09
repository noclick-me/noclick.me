import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:meta/meta.dart' show required;
import 'package:http/http.dart' as http;

/// Information about current rate limits.
class RateLimitInfo {
  /// The maximum number of request that can be done for a period of time.
  ///
  /// The period of time is unknown but it ends in [reset] time.
  final int limit;

  /// The remaining number of requests available until they are [reset].
  final int remaining;

  /// The remaining time until the limits are reset.
  final Duration reset;

  /// Creates a [RateLimitInfo].
  ///
  /// All arguments should be non-null.
  const RateLimitInfo({
    @required this.limit,
    @required this.remaining,
    @required this.reset,
  })  : assert(limit != null),
        assert(remaining != null),
        assert(reset != null);

  @override
  String toString() => '$runtimeType(limit: $limit, remaining: $remaining, '
      'reset: $reset)';
}

/// A progressive builder for [RateLimitInfo].
///
/// This is a mutable version of [RateLimitInfo], to make it easier to build it
/// progressively, as [RateLimitInfo] can only be created when we have all the
/// information and we know it is valid.
///
/// After assigning all values, just call [finish] to get the valid
/// [RateLimitInfo] or null if it's invalid.
class _RateLimitInfoBuilder {
  int limit;
  int remaining;
  Duration reset;
  _RateLimitInfoBuilder({
    this.limit,
    this.remaining,
    this.reset,
  });

  /// Returns the built [RateLimitInfo].
  ///
  /// If any field is missing, then it returns null.
  RateLimitInfo finish() => limit != null && remaining != null && reset != null
      ? RateLimitInfo(limit: limit, remaining: remaining, reset: reset)
      : null;
}

/// A response to a create URL request.
class CreateUrlResponse {
  /// The created URL.
  ///
  /// Can be null if [error] is non-null.
  final String url;

  /// An error trying to create the URL.
  ///
  /// Is null if there was no error creating the URL.
  final String error;

  /// Rate limit information associated with the response.
  ///
  /// Can be null if there was no rate limit information.
  final RateLimitInfo rateLimit;

  /// Creates a successful [CreateUrlResponse].
  ///
  /// [url] can't be null and [error] will be set to null.
  const CreateUrlResponse({@required this.url, this.rateLimit})
      : assert(url != null),
        error = null;

  /// Creates an failed [CreateUrlResponse].
  ///
  /// [error] can't be null and [url] will be set to null.
  const CreateUrlResponse.error(this.error, {this.rateLimit})
      : assert(error != null),
        url = null;

  @override
  String toString() =>
      '$runtimeType(url: $url, error: $error, rateLimit: $rateLimit)';
}

class NoClickService {
  static const SERVER_URL_DEFAULT = 'https://api.noclick.me';
  static const SERVER_URL_VAR_NAME = 'API_URL';
  static const MOCK_RESPONSE_VAR_NAME = 'TEST_API_MOCK_RESPONSE';
  static const MOCK_RESPONSE = CreateUrlResponse(
    url:
        'https://noclick.me/_test/Lorem_ipsum_dolor_sit_amet-_consectetur_adipiscing_elit._Ut_odio_felis-_maximus_eget_ex_nec-_varius_efficitur_lorem._Donec_imperdiet-_erat_vitae_rhoncus_iaculis-_metus_libero_accumsan_sapien-_nec_convallis_nisl_mauris_at_enim._Quisque_dui_lacus-_mollis_ac_ultricies_id-_facilisis_at_nunc._Integer_ullamcorper_in_elit_eget_volutpat._Curabitur_tristique-_metus_sed_tincidunt_egestas-_leo_velit_facilisis_turpis-_eu_auctor_ligula_magna_varius_est._Fusce_iaculis_convallis_sapien_et_accumsan._Curabitur_tortor_nisl-_varius_nec_posuere_non-_fringilla_ut_metus_tortor_nisl-_varius_nec_posuere_non-_fringilla_ut_metus',
    rateLimit: RateLimitInfo(
      limit: 10,
      remaining: 9,
      reset: Duration(seconds: 10),
    ),
  );

  final Uri _serverUrl;

  Uri get serverUrl => _serverUrl;

  final http.Client httpClient;

  NoClickService({@required this.httpClient, Uri serverUrl})
      : assert(httpClient != null),
        _serverUrl = serverUrl ??
            Uri.parse(const String.fromEnvironment(SERVER_URL_VAR_NAME,
                defaultValue: SERVER_URL_DEFAULT));

  Future<CreateUrlResponse> createUrl(Uri url) async {
    final mockResponse = const String.fromEnvironment(MOCK_RESPONSE_VAR_NAME);
    if (mockResponse.toLowerCase() == 'true' || mockResponse == '1') {
      print('Mocking response: ${MOCK_RESPONSE}');
      return MOCK_RESPONSE;
    }
    final response = await httpClient.post('$_serverUrl/url',
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'url': url.toString(),
        }));

    // Try to get rate limit information. We just bail out on any errors (in
    // which case rateLimit will be passed as null to the CreateUrlResponse.
    final rateLimit = _RateLimitInfoBuilder();
    try {
      if (response.headers.containsKey('x-ratelimit-limit')) {
        rateLimit.limit = int.parse(response.headers['x-ratelimit-limit']);
      }
      if (response.headers.containsKey('x-ratelimit-remaining')) {
        rateLimit.remaining =
            int.parse(response.headers['x-ratelimit-remaining']);
      }
      if (response.headers.containsKey('x-ratelimit-reset')) {
        rateLimit.reset =
            Duration(seconds: int.parse(response.headers['x-ratelimit-reset']));
      }
    } on FormatException {
      // Ignore, even when this shouldn't happen, is not something the user have
      // to care about.
    }

    if (response.statusCode != 200) {
      return CreateUrlResponse.error(
        'Unable to create new URL, status=${response.statusCode}',
        rateLimit: rateLimit.finish(),
      );
    }

    return CreateUrlResponse(
      url: jsonDecode(response.body)['noclick_url'].toString(),
      rateLimit: rateLimit.finish(),
    );
  }
}
