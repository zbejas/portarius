import 'package:get/get.dart';

import 'package:portarius/pages/home/home.dart';

// List of all routes
List<GetPage> appRoutes() => [
      GetPage(
        name: '/',
        page: () => const HomePage(),
        transition: Transition.rightToLeft,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      /*GetPage(
        name: '/sign_in',
        page: () => const SignInPage(),
        // No middleware required for sign in page
        transition: Transition.leftToRight,
        transitionDuration: const Duration(milliseconds: 300),
      ),*/
    ];
