import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunch, launch;

/// Opens [url] in a browser/new tab) or shows an error if it can't be opened.
void launchUrl(String url, BuildContext context) async {
  String error;
  try {
    if (!await canLaunch(url) ||
        !await launch(url, forceWebView: true, enableJavaScript: true)) {
      error = "Don't know how to open this URL type";
    }
  } catch (e) {
    error = "Can't open URL: $e";
  }

  if (error != null) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
  }
}
