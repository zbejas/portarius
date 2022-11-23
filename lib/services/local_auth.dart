import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuthController extends GetxService {
  RxBool isAuthenticating = false.obs;
  RxBool isAuthenticated = false.obs;

  final LocalAuthentication localAuth = LocalAuthentication();

  Future<bool> hasBiometrics() async {
    final bool hasBiometrics = await localAuth.canCheckBiometrics;
    return hasBiometrics;
  }

  Future<bool> authenticate() async {
    final bool isAvailable = await hasBiometrics();
    if (!isAvailable) {
      return false;
    }

    isAuthenticating.value = true;
    final bool authenticated = await localAuth.authenticate(
        localizedReason: 'Authenticate to access Portarius',
        options: const AuthenticationOptions(
          stickyAuth: true,
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
    isAuthenticating.value = false;
    isAuthenticated.value = authenticated;
    return authenticated;
  }
}
