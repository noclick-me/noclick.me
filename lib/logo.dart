import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Consider resizing images using ResizeImage or by
    //       adding more assets with specific sizes.
    final image = Image.asset('assets/noclick.png');

    const logoTextStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );

    final text = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text('noclick', style: logoTextStyle),
        Text('.', style: logoTextStyle.copyWith(color: Colors.black)),
        const Text('me', style: logoTextStyle),
      ],
    );

    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: image,
        ),
        Expanded(
          flex: 2,
          child: FittedBox(fit: BoxFit.contain, child: text),
        ),
      ],
    );

    return AspectRatio(
      aspectRatio: 3,
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(flex: 4, child: logo),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: const NoClickTagLine(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoClickTagLine extends StatelessWidget {
  const NoClickTagLine();

  @override
  Widget build(BuildContext context) => Text(
        'Never click on a link again!',
        style: TextStyle(
          color: Colors.black,
        ),
      );
}
