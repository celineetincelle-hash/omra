import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalDB {
  static const String _boxName = 'omraTruckBox';
  static late Box _box;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // Méthodes pour le stockage non sécurisé (Hive)
  static void save(String key, dynamic value) {
    _box.put(key, value);
  }

  static dynamic get(String key, [dynamic defaultValue]) {
    return _box.get(key, defaultValue: defaultValue);
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  // Méthodes pour le stockage sécurisé (FlutterSecureStorage)
  static Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }
}
