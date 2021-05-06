import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class HttpClientProvider extends InheritedWidget {
  final http.Client client;
  const HttpClientProvider({
    Key? key,
    required this.client,
    required Widget child,
  }) : super(key: key, child: child);

  static HttpClientProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HttpClientProvider>();

  @override
  bool updateShouldNotify(HttpClientProvider old) => client != old.client;
}
