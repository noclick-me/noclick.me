import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_linkify/flutter_linkify.dart'
    show LinkifyOptions, SelectableLinkify;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunch, launch;

import '../logo.dart' show Logo;

class ShowUrlScreen extends StatelessWidget {
  final String url;

  const ShowUrlScreen(this.url, {Key key}) : super(key: key);

  void _launchUrl(String url, BuildContext context) async {
    String error;
    try {
      if (!await canLaunch(url) ||
          !await launch(url, forceWebView: true, enableJavaScript: true)) {
        error = "Don't know how to open this URL type";
      }
    } catch (e) {
      error = "Can't open URL: ${e.message}";
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
                                  onPressed: () => _launchUrl(url, context),
                                ),
                                SizedBox(width: 8.w),
                                TextButton.icon(
                                  icon: const Icon(Icons.copy),
                                  label: const Text('COPY'),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: url));
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
                            SelectableLinkify(
                              // XXX: We replace the '-' for non-breaking hyphen
                              // as hack to avoid the text to be wrapped at '-'
                              // because we couldn't find a more elegant way to
                              // do char-by-char wrapping in Flutter.
                              // This should eventually be
                              // TextAlign.justify too.
                              text: url.replaceAll('-', '\u2011'),
                              options: LinkifyOptions(
                                humanize: false,
                                defaultToHttps: true,
                                excludeLastPeriod: false,
                              ),
                              onOpen: (link) => _launchUrl(url, context),
                            ),
                          ],
                        ),
                      ),
                    ),
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
