import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'
    show Markdown, MarkdownStyleSheet;

import 'launch_url.dart' show launchUrl;

/// Load and show a markdown document from the assets.
class MarkdownAsset extends StatelessWidget {
  /// The location of the markdown asset to show.
  final String location;

  /// Creates a new markdown widget from [location].
  const MarkdownAsset({@required this.location, Key key})
      : assert(location != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(location),
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
