import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;

  Future<bool> initialize({
    Function(SpeechRecognitionError)? onError,
    Function(String)? onStatus,
  }) async {
    if (_isInitialized && _isAvailable) return true;

    try {
      _isAvailable = await _speechToText.initialize(
        onError: (val) {
          debugPrint('Speech error: ${val.errorMsg} - permanent: ${val.permanent}');
          onError?.call(val);
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          onStatus?.call(status);
        },
        debugLogging: kDebugMode,
      );
      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      debugPrint('SpeechService init error: $e');
      _isAvailable = false;
      return false;
    }
  }

  Future<bool> startListening({
    required Function(String text, bool isFinal) onResult,
    Function(double level)? onSoundLevelChange,
    String? localeId,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    if (!_isAvailable) {
      debugPrint('Speech recognition is not available on this platform/device.');
      return false;
    }

    try {
      // Find Indonesian locale if available, else system locale
      String? targetLocale = localeId;
      if (targetLocale == null) {
        final locales = await _speechToText.locales();
        final hasIndonesian = locales.any((l) => l.localeId.startsWith('id'));
        if (hasIndonesian) {
          targetLocale = 'id_ID';
        }
      }

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: SpeechListenOptions(
          localeId: targetLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          cancelOnError: false,
          partialResults: true,
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('SpeechService startListening error: $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
    } catch (e) {
      debugPrint('SpeechService stopListening error: $e');
    }
  }

  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        await _speechToText.cancel();
      }
    } catch (e) {
      debugPrint('SpeechService cancelListening error: $e');
    }
  }
}
