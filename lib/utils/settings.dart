import 'package:flutter/cupertino.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/services/storage.dart';

class SettingsManager extends ChangeNotifier {
  /// This is the [Endpoint] that is used for the Portainer API.
  /// If the [Endpoint] is null, it will be set to the first endpoint in the list.
  int? _selectedEndpointId;
  int? get selectedEndpointId => _selectedEndpointId;

  late bool _autoRefresh;
  bool get autoRefresh => _autoRefresh;

  late int _autoRefreshInterval;
  int get autoRefreshInterval => _autoRefreshInterval;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  set isAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  /// This is the [Endpoint] that is used for the Portainer API.
  /// Get the selected [Endpoint]

  /// This is the [Endpoint] that is used for the Portainer API.
  /// Set the [Endpoint]
  set selectedEndpointId(int? value) {
    _selectedEndpointId = value;
    notifyListeners();
  }

  /// Init the [SettingsManager] before running this.
  /// This will load the [Endpoint] from the [StorageManager].
  Future<void> init(StorageManager storage) async {
    _selectedEndpointId = await storage.loadEndpointId();
    _autoRefresh = await storage.loadAutoRefresh();
    _autoRefreshInterval = await storage.loadAutoRefreshInterval();
    _biometricEnabled = await storage.loadBiometric();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refreshSettings(StorageManager storage) async {
    _selectedEndpointId = await storage.loadEndpointId();
    _autoRefresh = await storage.loadAutoRefresh();
    _autoRefreshInterval = await storage.loadAutoRefreshInterval();
    _biometricEnabled = await storage.loadBiometric();
    notifyListeners();
  }
}
