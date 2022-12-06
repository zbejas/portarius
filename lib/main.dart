import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/routing/routes.dart';
import 'package:portarius/services/controllers/logger_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/messages.dart';
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
            title: 'dialog_main_work_in_progress'.tr,
            middleText: 'dialog_main_work_in_progress_text'.tr,
            textConfirm: 'dialog_ok'.tr,
            onConfirm: () {
              Get.back();
            },
          );
        },
      );
    }

    return GetMaterialApp(
      translations: Messages(),
      // try checking the locale of the device with Get.deviceLocale
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      debugShowCheckedModeBanner: false,
      title: 'Portarius',
      logWriterCallback: loggerController.logWriterCallback,
      getPages: appRoutes(),
      initialRoute: '/home',
      themeMode: settingsController.isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: Color(0xff7fabfe),
          primaryContainer: Color(0xffd0e4ff),
          secondary: Color(0xff9498a4),
          secondaryContainer: Color(0xffffdbcf),
          tertiary: Color(0xff006875),
          tertiaryContainer: Color(0xff95f0ff),
          appBarColor: Color(0xffffdbcf),
          error: Color(0xffb00020),
        ),
        usedColors: 1,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurfacesVariantDialog,
        blendLevel: 10,
        tabBarStyle: FlexTabBarStyle.forBackground,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 10,
          blendOnColors: false,
          defaultRadius: 15.0,
          sliderTrackHeight: 7,
          inputDecoratorFocusedBorderWidth: 1.5,
          navigationBarIndicatorOpacity: 0.15,
          navigationRailIndicatorOpacity: 0.15,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
      darkTheme: FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: Color(0xffadc6ff),
          primaryContainer: Color(0xff00325b),
          secondary: Color(0xff2e3b4a),
          secondaryContainer: Color(0xff872100),
          tertiary: Color(0xff576f86),
          tertiaryContainer: Color(0xff004e59),
          appBarColor: Color(0xff872100),
          error: Color(0xffcf6679),
        ),
        usedColors: 1,
        surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
        blendLevel: 15,
        tabBarStyle: FlexTabBarStyle.forBackground,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          defaultRadius: 15.0,
          sliderTrackHeight: 7,
          inputDecoratorFocusedBorderWidth: 1.5,
          navigationBarIndicatorOpacity: 0.15,
          navigationRailIndicatorOpacity: 0.15,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        // fontFamily: GoogleFonts.notoSans().fontFamily,
      ),
    );
  }
}
