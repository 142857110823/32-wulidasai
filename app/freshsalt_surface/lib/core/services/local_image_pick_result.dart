import 'dart:typed_data';

class LocalImagePickResult {
  const LocalImagePickResult({
    required this.displayPath,
    required this.bytes,
  });

  final String displayPath;
  final Uint8List bytes;
}
