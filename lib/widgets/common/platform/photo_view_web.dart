import 'package:flutter/material.dart';

/// Web: `image_picker_for_web` returns a `blob:` URL, which loads like any
/// other network image. No `dart:io` anywhere in this file — that is the whole
/// point of the split.
Widget platformPhoto(
  String path, {
  required double height,
  required Widget Function() onError,
}) {
  return Image.network(
    path,
    height: height,
    width: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
        onError(),
  );
}
