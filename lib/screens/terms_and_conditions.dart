import 'package:flutter/material.dart';

import '../markdown_asset.dart' show MarkdownAsset;

/// Shows a Privacy Policy Screen.
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SafeArea(
        child: MarkdownAsset(location: 'doc/legal/terms.md'),
      ),
    );
  }
}
