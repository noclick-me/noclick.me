import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:noclick_me/logo.dart';

void main() {
  // FIXME: Normally we should configure this in flutter_test_config.dart (see
  // https://pub.dev/packages/golden_toolkit#loading-fonts) but there seems to
  // be a bug in Flutter (beta) that is preventing us from use that approach:
  // https://github.com/flutter/flutter/issues/72801
  setUp(() async => await loadAppFonts());

  group('Logo', () {
    testGoldens('should adapt to different screens', (tester) async {
      await tester.pumpWidgetBuilder(Center(child: Logo()));
      await multiScreenGolden(tester, 'logo', devices: [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
        Device.tabletLandscape,
        const Device(
          name: 'square-200x200',
          size: Size(200, 200),
        ),
        const Device(
          name: 'aspect-3:1',
          size: Size(300, 100),
        ),
        const Device(
          name: 'text-scale-3x',
          size: Size(300, 100),
          textScale: 3.0,
        ),
      ]);
    });
  });
}
