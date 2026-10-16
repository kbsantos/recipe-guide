import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the device-local PIN used to unlock cached recipes offline.
/// The default is retained for existing installations until the user changes it.
class LocalPinService {
  const LocalPinService();

  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'recipe_guide_local_unlock_pin_v1';
  static const defaultPin = '12345678';

  Future<String> readPin() async => await _storage.read(key: _pinKey) ?? defaultPin;

  Future<bool> verify(String candidate) async => candidate == await readPin();

  Future<void> changePin(String newPin) async {
    if (!RegExp(r'^\d{4,8}$').hasMatch(newPin)) {
      throw ArgumentError('PIN must contain 4 to 8 digits.');
    }
    await _storage.write(key: _pinKey, value: newPin);
  }
}
