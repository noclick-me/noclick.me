import 'dart:math' show min;

import 'package:duration/duration.dart' show prettyDuration;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_markdown/flutter_markdown.dart'
    show MarkdownBody, MarkdownStyleSheet;
import 'package:flutter_linkify/flutter_linkify.dart'
    show LinkifyOptions, Linkify;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../launch_url.dart' show launchUrl;
import '../logo.dart' show Logo;
import '../net.dart' show CreateUrlResponse, RateLimitInfo;

class ShowUrlScreen extends StatelessWidget {
  // It would make more sense to declare our own type here, but we want to keep
  // it pragmatic at the moment, as this screen will always really show
  // a response to a create URL API request. We'll delay the extra layers of
  // abstraction until this changes (if it does).
  final CreateUrlResponse response;

  const ShowUrlScreen(this.response, {Key key})
      : assert(response != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // TODO: Use a LayoutBuilder for each component that needs to adapt to
        // the screen size instead of one for the whole widget.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 0.04.sh),
                  SizedBox(
                    width: min(400, constraints.maxWidth),
                    child: const Logo(),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 0.03.sh, bottom: 0.01.sh),
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_link),
                        label: const Text('NEW LINK'),
                        onPressed: () => Navigator.pop(context)),
                  ),
                  SizedBox(
                    width: 0.9.sw,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 25.h,
                          horizontal: 8.w,
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('OPEN'),
                                  onPressed: () =>
                                      launchUrl(response.url, context),
                                ),
                                SizedBox(width: 8.w),
                                TextButton.icon(
                                  icon: const Icon(Icons.copy),
                                  label: const Text('COPY'),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: response.url));
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('Copied to clipboard!')),
                                      );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Linkify(
                                // XXX: We replace the '-' for non-breaking hyphen
                                // as hack to avoid the text to be wrapped at '-'
                                // because we couldn't find a more elegant way to
                                // do char-by-char wrapping in Flutter.
                                // This should eventually be
                                // TextAlign.justify too.
                                text: response.url.replaceAll('-', '\u2011'),
                                options: LinkifyOptions(
                                  humanize: false,
                                  defaultToHttps: true,
                                  excludeLastPeriod: false,
                                ),
                                onOpen: (link) =>
                                    launchUrl(response.url, context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 50.h,
                      horizontal: 25.w,
                    ),
                    child: response.rateLimit != null
                        ? RateLimitMessage(response.rateLimit)
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A message to display a [RateLimitInfo].
class RateLimitMessage extends StatelessWidget {
  /// The [RateLimitInfo] to display.
  final RateLimitInfo limit;

  /// Creates a [RateLimitMessage].
  ///
  /// [limit] must be non-null.
  const RateLimitMessage(this.limit) : assert(limit != null);

  /// Shows the [limit.reset] information in a human readable form.
  String get reset =>
      prettyDuration(limit.reset, delimiter: ', ', conjunction: ' and ');

  @override
  Widget build(BuildContext context) => MarkdownBody(
        onTapLink: (text, href, title) => launchUrl(href, context),
        styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.spaceBetween),
        data: '''\
There are **${limit.remaining}** requests left for today (will be reset to
${limit.limit} in $reset). This limitation exists to keep running costs
manageable. If you would like to see these limitations relaxed or completely
removed, please consider [supporting
us](https://github.com/llucax/llucax/blob/main/sponsoring-platforms.md)!''',
      );
}
