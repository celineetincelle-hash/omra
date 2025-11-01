import 'package:flutter/material.dart';
import 'package:omra_track/features/assistant/voice_assistant_service.dart';

class VoiceAssistantProvider extends ChangeNotifier {
  final VoiceAssistantService _service = VoiceAssistantService();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String? _lastRecognizedText;
  VoiceCommand? _lastCommand;
  String _currentLanguage = 'ar';

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  String? get lastRecognizedText => _lastRecognizedText;
  VoiceCommand? get lastCommand => _lastCommand;
  String get currentLanguage => _currentLanguage;

  Future<void> initialize({String language = 'ar'}) async {
    _currentLanguage = language;
    await _service.initialize(language: language);
    _isInitialized = _service.isInitialized;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    notifyListeners();
    
    await _service.speak(text, language: _currentLanguage);
    
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _service.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<VoiceCommand?> listenForCommand() async {
    if (!_isInitialized) {
      await initialize(language: _currentLanguage);
    }

    _isListening = true;
    _lastRecognizedText = null;
    _lastCommand = null;
    notifyListeners();

    try {
      final recognizedText = await _service.listen(language: _currentLanguage);
      
      if (recognizedText != null && recognizedText.isNotEmpty) {
        _lastRecognizedText = recognizedText;
        _lastCommand = _service.parseCommand(recognizedText, _currentLanguage);
      }
    } catch (e) {
      print('Error listening for command: $e');
    } finally {
      _isListening = false;
      notifyListeners();
    }

    return _lastCommand;
  }

  Future<void> stopListening() async {
    await _service.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
