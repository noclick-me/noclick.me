import 'package:flutter/material.dart';

import '../markdown_asset.dart' show MarkdownAsset;

/// Shows a Privacy Policy Screen.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: MarkdownAsset(location: 'doc/legal/privacy.md'),
      ),
    );
  }
}
