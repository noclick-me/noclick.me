import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'launch_url.dart' show launchUrl;

/// Load and show a markdown document from the assets.
class MarkdownAsset extends StatelessWidget {
  /// The location of the markdown asset to show.
  final String location;

  /// If true it will include padding or scrolling behavior.
  final bool standalone;

  /// The alignment of the markdown text.
  final WrapAlignment textAlign;

  /// Creates a new markdown widget from [location].
  const MarkdownAsset(
      {required this.location,
      this.standalone = true,
      this.textAlign = WrapAlignment.spaceBetween,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(location),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final style = MarkdownStyleSheet.fromTheme(Theme.of(context))
                .copyWith(textAlign: textAlign);

            if (standalone) {
              return Markdown(
                data: snapshot.data!,
                styleSheet: style,
                onTapLink: (text, href, title) => launchUrl(href, context),
              );
            }
            return MarkdownBody(
              data: snapshot.data!,
              styleSheet: style,
              onTapLink: (text, href, title) => launchUrl(href, context),
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
