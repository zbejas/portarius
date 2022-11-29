import 'package:get/get.dart';

import 'package:portarius/pages/home/home.dart';
import 'package:portarius/pages/settings/settings.dart';
import 'package:portarius/pages/userdata/userdata.dart';

// List of all routes
List<GetPage> appRoutes() => [
      GetPage(
        name: '/',
        page: () => const HomePage(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 150),
      ),
      GetPage(
        name: '/settings',
        page: () => const SettingsPage(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 150),
      ),
      GetPage(
        name: '/userdata',
        page: () => const UserDataPage(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 150),
      ),
    ];
