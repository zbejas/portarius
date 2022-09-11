import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portarius/services/remote.dart';
import 'package:provider/provider.dart';

import '../models/portainer/token.dart';
import '../models/portainer/user.dart';

class StorageManager extends ChangeNotifier {
  /// Encryption key used to encrypt and decrypt the data.
  final String encryptionKey;

  /// Stores the token for the API calls, username, password and host URL.
  late Box<dynamic>? _storageBox;
  bool isInitialized = false;

  /// PackkageInfo
  late PackageInfo _packageInfo;
  get packageInfo => _packageInfo;

  /// Saved user list
  List<User> _savedUsers = [];
  get savedUsers => _savedUsers;

  StorageManager(this.encryptionKey) : super();

  /// Initializes the [StorageManager].
  /// This method is called when the app is started.
  /// It opens the local storage.
  /// If the storage is empty, it will create a new one.
  Future<void> init(BuildContext context) async {
    try {
      _storageBox = await Hive.openBox('portarius',
          encryptionCipher: HiveAesCipher(base64Decode(encryptionKey)));
    } catch (e) {
      print(e);
      return;
    }

    _packageInfo = await PackageInfo.fromPlatform();

    if (_savedUsers.isEmpty) {
      List<dynamic> tempUserStorage =
          await _storageBox!.get('savedUsers', defaultValue: []);
      _savedUsers = tempUserStorage
          .map<User>(
            (user) => User(
                username: user.username,
                hostUrl: user.hostUrl,
                password: user.password,
                token: user.token,
                tokenManuallySet: user.tokenManuallySet),
          )
          .toList();
    }

    // ignore: use_build_context_synchronously
    await initUser(context);

    isInitialized = true;
    notifyListeners();
  }

  /// Load user data
  /// This method is called when the user is authenticated.
  /// It loads the user data from the local storage.
  /// It will also check if the token is valid.
  /// If the token is not valid, it will try to auth the user again.
  /// If the token is valid, it will return the user.
  /// If the token is null, it will return null.
  Future<void> initUser(BuildContext context) async {
    User providedUser = Provider.of<User>(context, listen: false);
    User? user = await _storageBox!.get('user');

    if (user == null || user.hostUrl.isEmpty) {
      return;
    }

    print('manually set: ${user.tokenManuallySet}');
    if (!user.tokenManuallySet &&
        !(await RemoteService().isTokenValid(user)) &&
        user.password.isNotEmpty &&
        user.username.isNotEmpty) {
      Token? token = await RemoteService().authPortainer(
        user.username,
        user.password,
        user.hostUrl,
      );

      if (token == null) {
        return;
      }

      if (!_savedUsers.contains(user)) {
        _savedUsers.add(user);
      }
      user.setToken(token);
      notifyListeners();
    }

    if (user.tokenManuallySet) {
      user.manuallySetToken(user.token!);
      notifyListeners();
    }

    if (!_savedUsers.contains(user)) {
      _savedUsers.add(user);
    }

    providedUser.setNewUser(user);
    saveUser(user);
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    /// If hostUrl ends with '/', remove it.
    if (user.hostUrl.endsWith('/')) {
      user.hostUrl = user.hostUrl.substring(0, user.hostUrl.length - 1);
    }

    await _storageBox!.put('user', user);
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _storageBox!.delete('user');
  }

  /// Save selected endpoint id
  Future<void> saveEndpointId(int id) async {
    await _storageBox!.put('endpoint', id);
    notifyListeners();
  }

  /// Load selected endpoint id
  Future<int?> loadEndpointId() async {
    return await _storageBox!.get('endpoint');
  }

  /// Clear selected endpoint id
  Future<void> clearEndpointId() async {
    await _storageBox!.delete('endpoint');
    notifyListeners();
  }

  /// Save auto-refresh data
  Future<void> saveAutoRefresh(bool autoRefresh) async {
    await _storageBox!.put('autoRefresh', autoRefresh);
    notifyListeners();
  }

  /// Load auto-refresh data
  Future<bool> loadAutoRefresh() async {
    return await _storageBox!.get('autoRefresh') ?? true;
  }

  /// Load auto-refresh interval data
  Future<int> loadAutoRefreshInterval() async {
    return await _storageBox!.get('autoRefreshInterval') ?? 10;
  }

  /// Save auto-refresh interval data
  Future<void> saveAutoRefreshInterval(int interval) async {
    await _storageBox!.put('autoRefreshInterval', interval);
    notifyListeners();
  }

  /// Load user list
  Future<void> loadUsers() async {
    List<dynamic> tempUserStorage =
        await _storageBox!.get('savedUsers', defaultValue: []);
    _savedUsers = tempUserStorage
        .map<User>((user) => User(
              username: user.username,
              hostUrl: user.hostUrl,
              password: user.password,
              token: user.token,
              tokenManuallySet: user.tokenManuallySet,
            ))
        .toList();
  }

  /// Save user list
  Future<void> saveUsers(List<User> userList) async {
    await _storageBox!.put('savedUsers', userList);
    notifyListeners();
  }

  /// Add to user list
  Future<void> addUserToList(User user) async {
    if (!_savedUsers.contains(user)) {
      _savedUsers.add(user);
    }

    await saveUsers(_savedUsers);
  }

  /// Remove from user list
  Future<void> removeUserFromList(User user) async {
    _savedUsers.removeWhere((element) =>
        element.username == user.username && element.hostUrl == user.hostUrl);
    await saveUsers(_savedUsers);
  }

  /// Replace user in user list with new user
  Future<void> replaceUserInList(User oldUser, User newUser) async {
    _savedUsers.removeWhere((element) =>
        element.username == oldUser.username &&
        element.hostUrl == oldUser.hostUrl);
    _savedUsers.add(newUser);
    await saveUsers(_savedUsers);
  }

  /// Clear user list
  Future<void> clearUsers() async {
    await _storageBox!.delete('savedUsers');
    notifyListeners();
  }

  /// Refresh user list
  Future<void> refreshUsers() async {
    _savedUsers = [];
    await loadUsers();
    notifyListeners();
  }

  /// Load biometric data
  Future<bool> loadBiometric() async {
    return await _storageBox!.get('biometric', defaultValue: false);
  }

  /// Save biometric data
  Future<void> saveBiometric(bool biometric) async {
    await _storageBox!.put('biometric', biometric);
    notifyListeners();
  }

  /// Returns the [Box]
  Box<dynamic>? get storageBox => _storageBox;
}
