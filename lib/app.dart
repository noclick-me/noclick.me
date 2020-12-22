import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home.dart' show Home;

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(
          builder: (context) {
            ScreenUtil.init(
              context,
              designSize: Size(1080, 1920),
              allowFontScaling: true,
            );
            return Home();
          },
        ),
      );
}
