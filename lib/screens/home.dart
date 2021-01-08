import 'dart:math' show min;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../logo.dart' show Logo;
import '../url_form.dart' show UrlForm;

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = SizedBox(height: 0.04.sh);

    double adapt({
      num current,
      num atMost,
      num smallerThan,
      double thenUse,
      double andUse,
      num ifBiggerThan,
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
                    child: UrlForm(),
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
