import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:portarius/services/controllers/drawer_controller.dart';
import 'package:portarius/services/controllers/logger_controller.dart';

// Middleware for authentication check and redirect
// If user is not authenticated, redirect to sign in page
class DrawerMiddleware extends GetMiddleware {
  Logger _logger = Get.find<LoggerController>().logger;

  @override
  RouteSettings? redirect(String? route) {
    PortariusDrawerController drawerController = Get.find();

    if (route != null) {
      drawerController.setPage(route);
    }

    return null;
  }
}
