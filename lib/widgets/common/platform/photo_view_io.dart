import 'dart:io' show File;

import 'package:flutter/material.dart';

/// Android / iOS: the picker returns a real file path.
Widget platformPhoto(
  String path, {
  required double height,
  required Widget Function() onError,
}) {
  return Image.file(
    File(path),
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    // If the file was moved or the OS revoked access, fall back rather than
    // showing a broken-image icon in front of a judge.
    errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
        onError(),
  );
}
