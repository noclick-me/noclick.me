import 'package:flutter/material.dart';

import 'screens/home.dart' show Home;
import 'screenutil_builder.dart' show screenutilBuilder;

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: screenutilBuilder(child: Home()),
      );
}
