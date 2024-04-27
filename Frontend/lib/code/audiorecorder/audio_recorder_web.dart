// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:record/record.dart';

mixin AudioRecorderMixin {
  Future<void> recordFile(AudioRecorder recorder, RecordConfig config) {
    return recorder.start(config, path: '');
  }

  Future<Stream<List<int>>> recordStream(
      AudioRecorder recorder, RecordConfig config) async {
    final streamController = StreamController<List<int>>();
    final b = <Uint8List>[];

    final stream = await recorder.startStream(config);

    stream.listen(
      (data) {
        b.add(data);
        streamController.add(data);
      },
      onDone: () {
        streamController.close();
        downloadWebData(html.Url.createObjectUrl(html.Blob(b)));
      },
      onError: (error) {
        streamController.addError(error);
      },
      cancelOnError: true,
    );

    return streamController.stream;
  }

  void downloadWebData(String path) {
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = path
      ..style.display = 'none'
      ..download = 'audio.wav';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
  }
}
