import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget screenutilBuilder({required Widget child}) => ScreenUtilInit(
      designSize: Size(1080, 1920),
      builder: () => child,
    );
