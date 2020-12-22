import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'net.dart' show NoClickService;

class UrlForm extends StatefulWidget {
  UrlForm({Key key}) : super(key: key);

  @override
  _UrlFormState createState() => _UrlFormState();
}

class _UrlFormState extends State<UrlForm> {
  final _formKey = GlobalKey<FormState>();

  final _service = NoClickService();

  bool _submitting = false;

  TextFormField _field;

  final _fieldController = TextEditingController();

  FlatButton _button;

  final _fieldFocusNode = FocusNode();

  _UrlFormState() {
    _button = FlatButton(
      color: Colors.blue,
      child: Text('Expand', style: TextStyle(color: Colors.white)),
      onPressed: _submit,
    );
  }

  @override
  void dispose() {
    _fieldController.dispose();
    super.dispose();
  }

  bool get _isNarrow => 1.sw <= 500;

  /// Tries to fix and validate an URL.
  ///
  /// Validates an URL by parsing it with [Uri.parse()]. If this fails, a few
  /// heuristics are used to see if the URL matches some invalid but common
  /// usage forms, like "google.com", which parsed as a URI will be interpreted
  /// as a relative local path instead of a host name. Missing schemes are
  /// translated to https and only http and https are accepted as schemes.
  ///
  /// Returns an [Uri] if the URL is valid and [String] if there is an error
  /// (with an user-facing error description).
  dynamic _fixAndValidateHttpishUrl(String url) {
    const errorMsg = 'Please enter a valid http/https internet URL';

    if (url.isEmpty) {
      return errorMsg;
    }

    Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException {
      return errorMsg;
    }

    // If there is no scheme, we try adding https:// as scheme
    if (!uri.hasScheme) {
      try {
        uri = Uri.parse('https://' + url);
      } on FormatException {
        return errorMsg;
      }

      if (!uri.host.contains('.') ||
          uri.host.startsWith('.') ||
          uri.host.endsWith('.')) {
        return errorMsg;
      }
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'Only http/https URLs are supported';
    }

    return uri;
  }

  String _validator(String value) {
    final dynamic url = _fixAndValidateHttpishUrl(value);
    if (url is String) return url;
    assert(url is Uri);
    return null;
  }

  void _submit() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState.validate()) {
      final dynamic res = _fixAndValidateHttpishUrl(_fieldController.text);
      assert(res is Uri);
      final uri = res as Uri;
      _fieldController.text = uri.toString();

      setState(() => _submitting = true);

      void _trySubmit() async {
        // If the form is valid, display a Snackbar.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expanding ${uri}'),
          ),
        );

        try {
          final result = await _service.createUrl(uri);
          _fieldController.text = result;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not retrieve the page: $e'),
            ),
          );
        }
      }

      try {
        await _trySubmit();
      } finally {
        setState(() => _submitting = false);
        _fieldFocusNode.requestFocus();
        _fieldController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _fieldController.text.length,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _field = TextFormField(
      // XXX: this is supposed to be created automatically according to the
      // documentation, but for some reason it is null if I don't create it
      controller: _fieldController,
      autocorrect: false,
      focusNode: _fieldFocusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.url,
      autofocus: true,
      readOnly: _submitting,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'URL to expand',
      ),
      validator: _validator,
      onEditingComplete: _submit,
    );

    final children = <Widget>[
      _isNarrow
          ? Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: _field,
            )
          : Expanded(
              child: _field,
            ),
      _isNarrow
          ? _button
          : Padding(padding: EdgeInsets.only(left: 10.w), child: _button),
    ];

    return Form(
      key: _formKey,
      child: _isNarrow
          ? Column(
              mainAxisSize: MainAxisSize.max,
              children: children,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }
}
