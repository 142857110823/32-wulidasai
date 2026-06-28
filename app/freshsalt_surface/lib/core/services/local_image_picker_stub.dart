import 'local_image_pick_result.dart';
import 'local_image_picker.dart';

Future<LocalImagePickResult?> pickLocalImage() {
  LocalImagePicker.setStatus('unsupported');
  throw UnsupportedError('Local image picking is not supported on this platform.');
}
