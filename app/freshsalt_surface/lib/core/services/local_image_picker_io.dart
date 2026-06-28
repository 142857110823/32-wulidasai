import 'package:file_picker/file_picker.dart';

import 'local_image_pick_result.dart';
import 'local_image_picker.dart';

Future<LocalImagePickResult?> pickLocalImage() async {
  LocalImagePicker.setStatus('opening_native');
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['png', 'jpg', 'jpeg'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) {
    LocalImagePicker.setStatus('cancelled');
    return null;
  }

  final file = result.files.first;
  final bytes = file.bytes;
  final displayPath = (file.path != null && file.path!.isNotEmpty)
      ? file.path!
      : file.name;
  if (bytes == null || displayPath.isEmpty) {
    LocalImagePicker.setStatus('invalid_selection');
    return null;
  }

  LocalImagePicker.setStatus('loaded');

  return LocalImagePickResult(
    displayPath: displayPath,
    bytes: bytes,
  );
}
