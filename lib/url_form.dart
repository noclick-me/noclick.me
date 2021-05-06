import 'dart:async' show FutureOr;

import 'package:flutter/material.dart' hide HttpClientProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'net.dart' show NoClickService, CreateUrlResponse;
import 'provider/http_client_provider.dart' show HttpClientProvider;

class UrlForm extends StatefulWidget {
  final FutureOr<void> Function(CreateUrlResponse createUrlResponse)? onSuccess;
  UrlForm({this.onSuccess, Key? key}) : super(key: key);

  @override
  _UrlFormState createState() => _UrlFormState();
}

class _UrlFormState extends State<UrlForm> {
  final _formKey = GlobalKey<FormState>();

  bool _submitting = false;

  final _fieldController = TextEditingController();

  late final TextFormField _field;

  late final TextButton _button;

  final _fieldFocusNode = FocusNode();

  _UrlFormState() {
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

    final flatButtonStyle = TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.blue,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
    );

    _button = TextButton(
      style: flatButtonStyle,
      child: Text('Expand'),
      onPressed: _submit,
    );
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  bool _isNarrow(BoxConstraints constraints) => constraints.maxWidth <= 500;

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

    // If there is no scheme, we add https:// as scheme
    if (!uri.hasScheme) {
      if (url.startsWith('//')) {
        uri = Uri.parse('https:' + url);
      } else if (url.startsWith('/')) {
        uri = Uri.parse('https:/' + url);
      } else {
        uri = Uri.parse('https://' + url);
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

  String? _validator(String? value) {
    final dynamic url = _fixAndValidateHttpishUrl(value!);
    if (url is String) return url;
    assert(url is Uri);
    return null;
  }

  void _submit() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      final dynamic res = _fixAndValidateHttpishUrl(_fieldController.text);
      assert(res is Uri);
      final uri = res as Uri;
      _fieldController.text = uri.toString();

      setState(() => _submitting = true);

      // If the form is valid, display a Snackbar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Expanding ${uri}'),
          ),
        );

      final service =
          NoClickService(httpClient: HttpClientProvider.of(context)!.client);

      CreateUrlResponse response;
      try {
        response = await service.createUrl(uri);
      } catch (e) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Could not retrieve the page: ${e}'),
            ),
          );
        _fieldFocusNode.requestFocus();
        _fieldController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _fieldController.text.length,
        );
        return;
      } finally {
        setState(() => _submitting = false);
      }

      if (response.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('The URL could not be expanded: ${response.error}'),
            ),
          );
        _fieldFocusNode.requestFocus();
        _fieldController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _fieldController.text.length,
        );
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (widget.onSuccess != null) {
        await widget.onSuccess!(response);
      }

      setState(() => _fieldController.clear());
      _formKey.currentState!.reset();
      _fieldFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) => _isNarrow(constraints)
                ? _NarrowUrlForm(_field, _button)
                : _WideUrlForm(_field, _button),
          ),
        ),
      );
}

class _NarrowUrlForm extends StatelessWidget {
  final Widget field;
  final Widget button;
  const _NarrowUrlForm(this.field, this.button);
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: field,
          ),
          button,
        ],
      );
}

class _WideUrlForm extends StatelessWidget {
  final Widget field;
  final Widget button;
  const _WideUrlForm(this.field, this.button);
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: field,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: button,
          ),
        ],
      );
}
