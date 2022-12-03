import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/routing/routes.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/service_controller.dart';

void main() async {
  await ServiceController().initServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final LoggerController loggerController = Get.find();
    final SettingsController settingsController = Get.find();

    // Show a dialog that tells the user that this
    // is a work in progress
    if (!kDebugMode) {
      Future.delayed(
        const Duration(seconds: 3),
        () {
          Get.defaultDialog(
            title: 'Work in progress',
            middleText:
                'This app is still a work in progress. The design is not final and the functionality is limited.',
            textConfirm: 'OK',
            onConfirm: () {
              Get.back();
            },
          );
        },
      );
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portarius',
      logWriterCallback: loggerController.logWriterCallback,
      getPages: appRoutes(),
      initialRoute: '/home',
      themeMode: settingsController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,

      /// Generated from https://rydmike.com/flexcolorscheme/ playground.
      /// This is the color scheme used in the app.
      theme: FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: Color(0xff70a1ff),
          primaryContainer: Color(0xffd0e4ff),
          secondary: Color(0xffac3306),
          secondaryContainer: Color(0xffffdbcf),
          tertiary: Color(0xff006875),
          tertiaryContainer: Color(0xff95f0ff),
          appBarColor: Color(0xffffdbcf),
          error: Color(0xffb00020),
        ),
        usedColors: 1,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 20,
        appBarOpacity: 0.95,
        tooltipsMatchBackground: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendOnColors: false,
          defaultRadius: 15.0,
          textButtonRadius: 15.0,
          elevatedButtonRadius: 40.0,
          outlinedButtonRadius: 40.0,
          inputDecoratorRadius: 40.0,
          fabRadius: 20.0,
          cardRadius: 15.0,
          popupMenuRadius: 11.0,
          dialogRadius: 20.0,
          timePickerDialogRadius: 20.0,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xff9fc9ff),
          primaryContainer: Color(0xff00325b),
          secondary: Color(0xffffb59d),
          secondaryContainer: Color(0xff872100),
          tertiary: Color(0xff86d2e1),
          tertiaryContainer: Color(0xff004e59),
          appBarColor: Color(0xff872100),
          error: Color(0xffcf6679),
        ),
        usedColors: 1,
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 20,
        appBarStyle: FlexAppBarStyle.background,
        appBarOpacity: 0.90,
        appBarElevation: 2.0,
        surfaceTint: const Color(0xff70a1ff),
        tooltipsMatchBackground: true,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 30,
          defaultRadius: 15.0,
          textButtonRadius: 15.0,
          elevatedButtonRadius: 40.0,
          outlinedButtonRadius: 40.0,
          inputDecoratorRadius: 40.0,
          fabRadius: 20.0,
          cardRadius: 15.0,
          popupMenuRadius: 11.0,
          dialogRadius: 20.0,
          timePickerDialogRadius: 20.0,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
    );
  }
}
