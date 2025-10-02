// ignore_for_file: public_member_api_docs

import 'package:waveform_recorder/waveform_recorder.dart';
// ignore: depend_on_referenced_packages
import 'package:waveform_flutter/waveform_flutter.dart' as waveform;

class FakeWaveformRecorderController extends WaveformRecorderController {
  final Stopwatch _stopwatch = Stopwatch();

  /// Returns the elapsed time since the recording started,
  /// excluding any paused time.
  @override
  Duration get timeElapsed => _stopwatch.elapsed;

  ///Indicates whether audio recording is currently paused or not.
  @override
  bool get isPaused => !_stopwatch.isRunning;

  /// Indicates whether audio recording is currently in progress.
  bool _isRecording = false;
  @override
  bool get isRecording => _isRecording;

  @override
  Stream<waveform.Amplitude> get amplitudeStream =>
      Stream<waveform.Amplitude>.empty().asBroadcastStream();

  @override
  Future<void> startRecording() async {
    _isRecording = true;
    _stopwatch.start();
    notifyListeners();
  }

  @override
  Future<void> stopRecording() async {
    _isRecording = false;
    _stopwatch.stop();
    _stopwatch.reset();
    notifyListeners();
  }

  @override
  Future<void> pauseRecording() async {
    _stopwatch.stop();
    notifyListeners();
  }

  @override
  Future<void> resumeRecording() async {
    _stopwatch.start();
    notifyListeners();
  }

  @override
  Future<void> cancelRecording() async {
    _isRecording = false;
    _stopwatch.stop();
    _stopwatch.reset();
    notifyListeners();
  }

  @override
  void clear() {
    _stopwatch.stop();
    _stopwatch.reset();
    notifyListeners();
  }
}
