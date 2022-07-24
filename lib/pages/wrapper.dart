import 'package:flutter/material.dart';
import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/pages/loading/loading.dart';
import 'package:portarius/services/local_auth.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/settings.dart';
import 'package:provider/provider.dart';
import 'auth/authpage.dart';
import 'home/home.dart';

/// [Wrapper] for switching between [AuthPage] and [HomePage].
/// This is the main entry point of the app.
/// It uses [Provider] to provide the [User] model to the [HomePage].
/// The [User] model is used to store the username, password and host URL of the user.
/// [Token] is also stored in this model, but can be null.
/// The token is used to access the Portainer API.
/// With no token, the user is redirected to the [AuthPage].
/// With a token, the user is redirected to the [HomePage].
class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool isAuthing = false;
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: true);
    bool isAuthenticated = settings.isAuthenticated;

    if (!storage.isInitialized && !settings.isInitialized) {
      return const LoadingPage();
    }

    debugPrint('Biometrics: ${settings.biometricEnabled}');
    debugPrint('Authenticated: ${isAuthenticated}');
    debugPrint('User: ${user.token?.jwt}');

    if (settings.biometricEnabled && !isAuthenticated) {
      if (mounted && !isAuthing) {
        _runBiometrics(settings);
      }
      return const LoadingPage();
    }

    if (user.token != null && settings.biometricEnabled && isAuthenticated) {
      return const HomePage();
    }

    if (user.token != null && !settings.biometricEnabled) {
      return const HomePage();
    }

    return const AuthPage();
  }

  _runBiometrics(SettingsManager settings) async {
    isAuthing = true;
    final result = await LocalAuthManager.authenticate();
    setState(() {
      settings.isAuthenticated = result;
      isAuthing = false;
    });
  }
}
