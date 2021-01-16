import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:meta/meta.dart' show required;
import 'package:http/http.dart' as http;

class NoClickService {
  static const SERVER_URL_DEFAULT = 'https://api.noclick.me';
  static const SERVER_URL_VAR_NAME = 'API_URL';
  static const MOCK_RESPONSE_VAR_NAME = 'TEST_API_MOCK_RESPONSE';
  static const MOCK_RESPONSE =
      'https://noclick.me/_test/Lorem_ipsum_dolor_sit_amet-_consectetur_adipiscing_elit._Ut_odio_felis-_maximus_eget_ex_nec-_varius_efficitur_lorem._Donec_imperdiet-_erat_vitae_rhoncus_iaculis-_metus_libero_accumsan_sapien-_nec_convallis_nisl_mauris_at_enim._Quisque_dui_lacus-_mollis_ac_ultricies_id-_facilisis_at_nunc._Integer_ullamcorper_in_elit_eget_volutpat._Curabitur_tristique-_metus_sed_tincidunt_egestas-_leo_velit_facilisis_turpis-_eu_auctor_ligula_magna_varius_est._Fusce_iaculis_convallis_sapien_et_accumsan._Curabitur_tortor_nisl-_varius_nec_posuere_non-_fringilla_ut_metus_tortor_nisl-_varius_nec_posuere_non-_fringilla_ut_metus';

  final Uri _serverUrl;

  Uri get serverUrl => _serverUrl;

  final http.Client httpClient;

  NoClickService({@required this.httpClient, Uri serverUrl})
      : assert(httpClient != null),
        _serverUrl = serverUrl ??
            Uri.parse(const String.fromEnvironment(SERVER_URL_VAR_NAME,
                defaultValue: SERVER_URL_DEFAULT));

  Future<String> createUrl(Uri url) async {
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

    if (response.statusCode != 200) {
      return 'NOT OK: status=${response.statusCode}';
    }

    return jsonDecode(response.body)['noclick_url'].toString();
  }
}
