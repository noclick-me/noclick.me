import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:noclick_me/logo.dart';

void main() {
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
