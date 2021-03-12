import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'
    show Markdown, MarkdownStyleSheet;

import '../launch_url.dart' show launchUrl;

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
              onTapLink: (text, href, title) => launchUrl(href, context),
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
