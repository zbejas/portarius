import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuthManager {
  static final LocalAuthentication _instance = LocalAuthentication();

  static Future<bool> hasBiometrics() {
    return _instance.canCheckBiometrics;
  }

  static Future<bool> deviceSupported() async {
    try {
      return await _instance.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) {
      return false;
    }

    try {
      return await _instance.authenticate(
          localizedReason: 'Authenticate to access Portarius',
          options: const AuthenticationOptions(
            stickyAuth: true,
            useErrorDialogs: true,
          ),
          authMessages: [
            const AndroidAuthMessages(
              signInTitle: 'Oops! Biometric authentication required!',
              cancelButton: 'No thanks',
            ),
            const IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ]);
    } catch (e) {
      return false;
    }
  }
}
