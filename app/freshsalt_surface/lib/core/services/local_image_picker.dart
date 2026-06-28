import 'package:flutter/foundation.dart';

import 'local_image_pick_result.dart';
import 'local_image_picker_stub.dart'
    if (dart.library.html) 'local_image_picker_web.dart'
    if (dart.library.io) 'local_image_picker_io.dart';

class LocalImagePicker {
  static final ValueNotifier<String> status = ValueNotifier<String>('idle');

  static void setStatus(String value) {
    status.value = value;
  }

  static Future<LocalImagePickResult?> pickImage() {
    setStatus('opening');
    return pickLocalImage();
  }
}
