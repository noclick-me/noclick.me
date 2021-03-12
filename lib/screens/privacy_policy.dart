import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'
    show Markdown, MarkdownStyleSheet;
import 'package:url_launcher/url_launcher.dart' show canLaunch, launch;

/// Shows a Privacy Policy Screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: PrivacyPolicy(),
      ),
    );
  }
}

/// Load and show the privacy policy form the assets.
class PrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future:
            DefaultAssetBundle.of(context).loadString('doc/legal/privacy.md'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              onTapLink: (text, href, title) => _launchUrl(href, context),
              styleSheet:
                  MarkdownStyleSheet(textAlign: WrapAlignment.spaceBetween),
              data: snapshot.data,
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return CircularProgressIndicator();
        },
      );
}

/// Opens [url] in a browser/new tab) or shows an error if it can't be opened.
void _launchUrl(String url, BuildContext context) async {
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
