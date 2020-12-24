import 'dart:io' show X509Certificate, HttpClient;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show runApp;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' show IOClient;

import 'app.dart' show App;
import 'providers.dart' show HttpClientProvider;

// XXX: All this is a big hack to be able to connect to self-signed certificates
//      (which opens the door to any other bad certificate, so this is really
//      really a BAD THING (TM). It should only be enabled in debug or test
//      builds or removed completely in the future, once a good and simple way
//      to test is found.
http.Client createHttpClient() {
  if (kIsWeb) return http.Client();
  final ioHttpClient = HttpClient();
  ioHttpClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  return IOClient(ioHttpClient);
}

void main() => runApp(
      HttpClientProvider(
        client: createHttpClient(),
        child: App(),
      ),
    );
