/// Picks the right way to display a photo the farmer just captured.
///
/// On Android and iOS the picker hands back a file path, which needs
/// `dart:io`. On the web it hands back a `blob:` URL, which needs
/// `Image.network` and must never see `dart:io` at all — importing it would
/// break the web build outright.
///
/// The conditional export keeps that difference in one place, so every screen
/// just calls `platformPhoto(...)` and never learns which platform it is on.
library;
export 'photo_view_io.dart' if (dart.library.js_interop) 'photo_view_web.dart';
