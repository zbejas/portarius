/*
dis be example from old code
todo: delete dis brefore commit

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// Middleware for authentication check and redirect
// If user is not authenticated, redirect to sign in page
class AuthMiddleware extends GetMiddleware {
  Logger logger = MyLogger.logger;
  List<String> authNotRequired = [
    '/sign_in',
    '/sign_up',
  ];

  @override
  RouteSettings? redirect(String? route) {
    AuthService authService = Get.find();

    // If user is not authenticated and route is not in authNotRequired list
    // redirect to sign in page
    if (!authService.isAuthed && !authNotRequired.contains(route)) {
      logger.w('User not logged in. Redirecting to /sign_in.');
      return const RouteSettings(name: '/sign_in');
    }

    DeviceManager deviceManager = Get.find();

    // If user is authenticated and device list is not initialized
    // initialize the device list
    if (!deviceManager.isInitialized) {
      logger
          .w('User logged in but device list not initialized. Initializing...');
      deviceManager.onInit();
    }

    return null;
  }
}*/
