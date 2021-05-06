import 'dart:math' show max, min;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../logo.dart' show Logo;
import '../markdown_asset.dart' show MarkdownAsset;
import '../url_form.dart' show UrlForm;
import 'show.dart' show ShowUrlScreen;
import 'privacy_policy.dart' show PrivacyPolicyScreen;

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = SizedBox(height: 0.04.sh);

    double adapt({
      required num current,
      required num smallerThan,
      required double thenUse,
      required double andUse,
      required num ifBiggerThan,
      num? atMost,
    }) {
      final minPixels = smallerThan;
      final maxPixels = ifBiggerThan;
      final minVal = thenUse;
      final maxVal = andUse;

      double r;

      if (current <= minPixels) {
        r = minVal.sw;
      } else if (current >= maxPixels) {
        r = maxVal.sw;
      } else {
        final ratio = (current - minPixels) / (maxPixels - minPixels);
        r = ((maxVal - minVal) * ratio + minVal).sw;
      }

      if (atMost != null) {
        r = min(atMost.toDouble(), r);
      }

      return r;
    }

    return Scaffold(
      body: SafeArea(
        // TODO: Use a LayoutBuilder for each component that needs to adapt to
        // the screen size instead of one for the whole widget.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  topPadding,
                  SizedBox(
                    width: min(400, constraints.maxWidth),
                    child: const Logo(),
                  ),
                  Container(
                    width: adapt(
                      current: constraints.maxWidth,
                      atMost: 1080,
                      smallerThan: 600,
                      thenUse: 1.0,
                      andUse: 0.8,
                      ifBiggerThan: 800,
                    ),
                    padding: EdgeInsets.only(
                      left: 0.01.sw,
                      right: 0.01.sw,
                      top: 0.05.sh,
                    ),
                    child: UrlForm(
                      onSuccess: (response) => Navigator.push<ShowUrlScreen>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowUrlScreen(response),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02.sw),
                    child: MarkdownAsset(
                      location: 'doc/sponsoring.md',
                      textAlign: WrapAlignment.center,
                      standalone: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.008.sw),
                    // MouseRegion is just a hack to get a nice mouse
                    // pointer until this issue is fixed:
                    // https://github.com/flutter/flutter_markdown/issues/233
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: MarkdownAsset(
                        location: 'doc/sponsoring-badges.md',
                        textAlign: WrapAlignment.center,
                        standalone: false,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0.02.sw),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        TextButton(
                          child: const Text('Privacy Policy'),
                          onPressed: () => Navigator.push<ShowUrlScreen>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen(),
                            ),
                          ),
                        ),
                        SizedBox(width: max(12.0, min(27.0, 0.02.sw))),
                        TextButton(
                          child: const Text('Licenses'),
                          onPressed: () => showLicensePage(
                            context: context,
                            applicationName: 'noclick.me',
                            applicationIcon: SizedBox(
                              width: 64,
                              height: 64,
                              child: Image.asset('assets/noclick.png'),
                            ),
                          ),
                        ),
                      ],
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
