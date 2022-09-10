import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:portarius/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../services/remote.dart';
import 'token.dart';

part '../hive/user.g.dart';

/// [User] model for Portainer.
///
/// This model is used to store the username, password and host URL of the user.
/// [Token] is also stored in this model, but can be null.
///
/// The token is used to access the Portainer API.
@HiveType(typeId: 0, adapterName: 'UserAdapter')
class User extends ChangeNotifier {
  /// [username] of the user.
  @HiveField(0)
  String username;

  /// [password] of the user.
  @HiveField(1)
  String password;

  /// [hostUrl] of the portainer API
  @HiveField(2)
  String hostUrl;

  /// [token] for the API calls
  @HiveField(3)
  late Token? token;

  /// is token manually set
  @HiveField(4)
  bool tokenManuallySet = false;

  User(
      {required this.username,
      required this.password,
      required this.hostUrl,
      this.token,
      this.tokenManuallySet = false});

  /// Tries to auth [User]
  ///
  /// If [Token] is returned, it is stored in [User]
  /// If [Token] is null, null is returned
  Future<Token?> authPortainer() async {
    Token? newToken = await RemoteService().authPortainer(
      username,
      password,
      hostUrl,
    );

    if (newToken == null) {
      return null;
    }

    if (newToken.jwt.isNotEmpty) {
      debugPrint('Setting new token.');
      token = newToken;
      notifyListeners();
    }

    return newToken;
  }

  /// Checks if [Token] is valid
  Future<bool> isTokenValid(Token token) async {
    return await RemoteService().isTokenValid(this);
  }

  /// Logs out the [User].
  /// It will remove [User] from Hive storage.
  /// It will also remove [Token] from [User].
  /// [BuildContext] is required to get the [StorageManager] from the [Provider]
  Future<void> logOutUser(BuildContext context) async {
    if (await RemoteService().logoutPortainer(this)) {
      var storage = Provider.of<StorageManager>(context, listen: false);
      await storage.clearUser();

      Future.delayed(const Duration(milliseconds: 100), () {
        username = '';
        password = '';
        hostUrl = '';
        resetToken();
      });
    } else {
      Toast.show('Logout failed.');
    }
  }

  void setToken(Token newToken) {
    token = newToken;
    notifyListeners();
  }

  void manuallySetToken(Token newToken) {
    token = newToken;
    tokenManuallySet = true;
    notifyListeners();
  }

  void resetToken() {
    if (tokenManuallySet) {
      return;
    }

    token = null;
    notifyListeners();
  }

  void setNewUser(User user) {
    username = user.username;
    password = user.password;

    if (user.hostUrl.endsWith('/')) {
      hostUrl = user.hostUrl.substring(0, user.hostUrl.length - 1);
    } else {
      hostUrl = user.hostUrl;
    }

    token = user.token;
    notifyListeners();
  }

  /// Operator == for [User]
  /// Two [User] are equal if their [username] and [hostUrl]  and [token] are equal.
  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          hostUrl == other.hostUrl;
}
