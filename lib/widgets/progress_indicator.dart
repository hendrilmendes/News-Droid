import 'package:flutter/material.dart';

Color progressIndicatorColor = Colors.blue;
Widget buildLoadingIndicator() {
  return CircularProgressIndicator.adaptive(
    backgroundColor: progressIndicatorColor,
  );
}
