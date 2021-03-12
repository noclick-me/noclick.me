import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:noclick_me/screenutil_builder.dart';
import 'package:noclick_me/screens/privacy_policy.dart';

void main() {
  Widget home() =>
      screenutilBuilder(child: Center(child: PrivacyPolicyScreen()));

  group('Home', () {
    testGoldens('should adapt to different screens', (tester) async {
      await tester.pumpWidgetBuilder(home());
      await multiScreenGolden(tester, 'privacy_policy-screens', devices: [
        Device.phone,
        Device.iphone11,
        Device.tabletPortrait,
        Device.tabletLandscape,
        const Device(
          name: 'vga',
          size: Size(640, 480),
        ),
        const Device(
          name: 'full_hd',
          size: Size(1920, 1080),
        ),
      ]);
    });

    testGoldens('should adapt to different text scales', (tester) async {
      await tester.pumpWidgetBuilder(home());
      await multiScreenGolden(tester, 'privacy_policy-text_scale', devices: [
        Device.phone,
        Device.phone.copyWith(
          name: 'phone-textscale_0.75x',
          textScale: 0.75,
        ),
        Device.phone.copyWith(
          name: 'phone-textscale_2x',
          textScale: 2.0,
        ),
        Device.phone.copyWith(
          name: 'phone-textscale_3x',
          textScale: 3.0,
        ),
      ]);
    });
  });
}
