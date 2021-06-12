import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunch, launch;

/// Opens [url] in a browser/new tab) or shows an error if it can't be opened.
void launchUrl(String? url, BuildContext context,
    {bool forceWebView = true}) async {
  void showError(String error) => ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(error),
      ),
    );

  if (url == null) {
    showError("Can't open a null URL");
    return;
  }

  try {
    if (!await canLaunch(url) ||
        !await launch(url,
            forceWebView: forceWebView, enableJavaScript: true)) {
      showError("Don't know how to open this URL type");
    }
  } catch (e) {
    showError("Can't open URL: $e");
  }
}
