import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget screenutilBuilder({@required Widget child}) => Builder(
      builder: (context) {
        ScreenUtil.init(
          context,
          designSize: Size(1080, 1920),
          allowFontScaling: true,
        );
        return child;
      },
    );
