import 'package:get/get.dart';
import 'package:portarius/components/routing/middleware/drawer_middleware.dart';

import 'package:portarius/pages/home/home.dart';
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
