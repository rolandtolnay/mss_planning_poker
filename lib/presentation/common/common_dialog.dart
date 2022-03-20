import 'package:flutter/material.dart';

import '../extensions/build_context_ext_screen_size.dart';
import 'max_width_container.dart';

class CommonDialog extends StatelessWidget {
  final Widget? child;

  const CommonDialog({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      maxWidth: kPhoneWidth,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 4,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24,
        ),
        child: child,
      ),
    );
  }
}
