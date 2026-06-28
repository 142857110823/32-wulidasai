// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'local_image_pick_result.dart';
import 'local_image_picker.dart';

Future<LocalImagePickResult?> pickLocalImage() async {
  LocalImagePicker.setStatus('preparing');
  html.document
      .querySelector('#freshsalt-local-image-picker')
      ?.remove();

  final input = html.FileUploadInputElement()
    ..accept = '.png,.jpg,.jpeg,image/png,image/jpeg'
    ..multiple = false
    ..id = 'freshsalt-local-image-picker';

  input.style
    ..position = 'fixed'
    ..left = '-9999px'
    ..top = '-9999px'
    ..width = '1px'
    ..height = '1px'
    ..opacity = '0'
    ..pointerEvents = 'none';

  html.document.body?.dataset['freshsaltPickerState'] = 'created';
  LocalImagePicker.setStatus('created');
  html.document.body?.append(input);

  final completer = Completer<LocalImagePickResult?>();
  StreamSubscription<html.Event>? focusSubscription;
  var sawChangeEvent = false;

  void cleanup() {
    focusSubscription?.cancel();
    input.remove();
  }

  void completeNull(String state) {
    if (!completer.isCompleted) {
      html.document.body?.dataset['freshsaltPickerState'] = state;
      LocalImagePicker.setStatus(state);
      completer.complete(null);
    }
    cleanup();
  }

  input.onChange.first.then((_) {
    sawChangeEvent = true;
    html.document.body?.dataset['freshsaltPickerState'] = 'changed';
    LocalImagePicker.setStatus('changed');
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completeNull('empty');
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.first.then((_) {
      final bytes = _coerceReaderResultToBytes(reader.result);
      if (bytes == null || bytes.isEmpty) {
        completeNull('decode_failed');
        return;
      }

      if (!completer.isCompleted) {
        html.document.body?.dataset['freshsaltPickerState'] = 'loaded';
        LocalImagePicker.setStatus('loaded');
        completer.complete(
          LocalImagePickResult(
            displayPath: file.name,
            bytes: bytes,
          ),
        );
      }
      cleanup();
    });

    reader.onError.first.then((_) {
      completeNull('read_error');
    });

    reader.readAsDataUrl(file);
  });

  focusSubscription = html.window.onFocus.listen((_) {
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (completer.isCompleted) {
        return;
      }
      if (sawChangeEvent) {
        return;
      }
      final hasSelection = input.files?.isNotEmpty == true;
      if (!hasSelection) {
        completeNull('cancelled');
      }
    });
  });

  html.document.body?.dataset['freshsaltPickerState'] = 'clicked';
  LocalImagePicker.setStatus('clicked');
  input.click();
  return completer.future;
}

Uint8List? _coerceReaderResultToBytes(Object? result) {
  if (result is ByteBuffer) {
    return Uint8List.view(result);
  }
  if (result is Uint8List) {
    return result;
  }
  if (result is List<int>) {
    return Uint8List.fromList(result);
  }
  if (result is String) {
    final commaIndex = result.indexOf(',');
    final payload = commaIndex >= 0 ? result.substring(commaIndex + 1) : result;
    try {
      return Uint8List.fromList(base64Decode(payload));
    } catch (_) {
      return null;
    }
  }
  return null;
}
