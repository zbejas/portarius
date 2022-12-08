import 'package:get/get.dart';
import 'package:portarius/components/routing/middleware/drawer_middleware.dart';

import 'package:portarius/pages/home/home.dart';
import 'package:portarius/pages/settings/pages/backup_restore.dart';
import 'package:portarius/pages/settings/pages/logs.dart';
import 'package:portarius/pages/settings/settings.dart';
import 'package:portarius/pages/userdata/add_server.dart';
import 'package:portarius/pages/userdata/userdata.dart';

// List of all routes
List<GetPage> appRoutes() => [
      GetPage(
        name: '/home',
        page: () => const HomePage(),
        middlewares: [DrawerMiddleware()],
        transition: Transition.noTransition,
        transitionDuration: const Duration(milliseconds: 150),
      ),
      GetPage(
        name: '/settings',
        page: () => const SettingsPage(),
        middlewares: [DrawerMiddleware()],
        transition: Transition.noTransition,
        transitionDuration: const Duration(milliseconds: 150),
      ),
      // secondary routes have transitions
      GetPage(
        name: '/settings/backup_restore',
        page: () => const BackupAndRestorePage(),
        middlewares: [DrawerMiddleware()],
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/settings/logs',
        page: () => const LogViewPage(),
        middlewares: [DrawerMiddleware()],
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: '/userdata',
        page: () => const UserDataPage(),
        middlewares: [DrawerMiddleware()],
        transition: Transition.noTransition,
        transitionDuration: const Duration(milliseconds: 150),
      ),
      GetPage(
        name: '/userdata/add_server',
        page: () => const ServerAddPage(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ];
