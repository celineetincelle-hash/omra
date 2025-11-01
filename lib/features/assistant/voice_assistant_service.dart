import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceAssistantService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  Future<void> initialize({String language = 'ar'}) async {
    try {
      // Initialize TTS
      await _flutterTts.setLanguage(language == 'ar' ? 'ar-SA' : language);
      await _flutterTts.setSpeechRate(0.5); // Slower for seniors
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('TTS Error: $msg');
      });

      // Initialize Speech Recognition
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing voice assistant: $e');
      _isInitialized = false;
    }
  }

  Future<void> speak(String text, {String? language}) async {
    try {
      if (language != null) {
        await _flutterTts.setLanguage(language == 'ar' ? 'ar-SA' : language);
      }
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<String?> listen({String language = 'ar'}) async {
    if (!_isInitialized) {
      debugPrint('Speech recognition not initialized');
      return null;
    }

    try {
      String? result;
      _isListening = true;

      await _speech.listen(
        onResult: (val) {
          result = val.recognizedWords;
        },
        localeId: language == 'ar' ? 'ar_SA' : language,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );

      // Wait for listening to complete
      await Future.delayed(const Duration(seconds: 10));
      _isListening = false;

      return result;
    } catch (e) {
      debugPrint('Error listening: $e');
      _isListening = false;
      return null;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      _isListening = false;
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    }
  }

  VoiceCommand? parseCommand(String text, String language) {
    final lowerText = text.toLowerCase().trim();

    if (language == 'ar') {
      // Arabic commands
      if (lowerText.contains('أين') || lowerText.contains('موقع') || lowerText.contains('مكان')) {
        return VoiceCommand.whereAmI;
      } else if (lowerText.contains('وقت') && lowerText.contains('صلاة')) {
        return VoiceCommand.prayerTime;
      } else if (lowerText.contains('ما الوقت') || lowerText.contains('كم الساعة')) {
        return VoiceCommand.whatTime;
      } else if (lowerText.contains('دواء') || lowerText.contains('علاج')) {
        return VoiceCommand.medication;
      } else if (lowerText.contains('صحة') || lowerText.contains('قلب')) {
        return VoiceCommand.health;
      } else if (lowerText.contains('طوارئ') || lowerText.contains('مساعدة')) {
        return VoiceCommand.emergency;
      }
    } else if (language == 'en') {
      // English commands
      if (lowerText.contains('where') || lowerText.contains('location')) {
        return VoiceCommand.whereAmI;
      } else if (lowerText.contains('prayer') && lowerText.contains('time')) {
        return VoiceCommand.prayerTime;
      } else if (lowerText.contains('what') && lowerText.contains('time')) {
        return VoiceCommand.whatTime;
      } else if (lowerText.contains('medication') || lowerText.contains('medicine')) {
        return VoiceCommand.medication;
      } else if (lowerText.contains('health')) {
        return VoiceCommand.health;
      } else if (lowerText.contains('emergency') || lowerText.contains('help')) {
        return VoiceCommand.emergency;
      }
    } else if (language == 'fr') {
      // French commands
      if (lowerText.contains('où') || lowerText.contains('position')) {
        return VoiceCommand.whereAmI;
      } else if (lowerText.contains('prière') && lowerText.contains('heure')) {
        return VoiceCommand.prayerTime;
      } else if (lowerText.contains('quelle') && lowerText.contains('heure')) {
        return VoiceCommand.whatTime;
      } else if (lowerText.contains('médicament')) {
        return VoiceCommand.medication;
      } else if (lowerText.contains('santé')) {
        return VoiceCommand.health;
      } else if (lowerText.contains('urgence') || lowerText.contains('aide')) {
        return VoiceCommand.emergency;
      }
    }

    return null;
  }

  void dispose() {
    _flutterTts.stop();
    _speech.stop();
  }
}

enum VoiceCommand {
  whereAmI,
  whatTime,
  prayerTime,
  medication,
  health,
  emergency,
}
