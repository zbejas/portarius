import 'dart:convert';
import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:portarius/models/portainer/token.dart';
import 'package:portarius/pages/auth/authpage.dart';
import 'package:portarius/pages/container/container_details.dart';
import 'package:portarius/pages/home/home.dart';
import 'package:portarius/pages/users/user_managment.dart';
import 'package:portarius/pages/wrapper.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/settings.dart';
import 'package:portarius/utils/style.dart';
import 'package:provider/provider.dart';
import 'models/portainer/user.dart';
import 'pages/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If platform is web, skip init
  if (!kIsWeb) {
    Hive.init((await path_provider.getApplicationDocumentsDirectory()).path);
  }

  Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(UserAdapter());

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  var containsEncryptionKey =
      await secureStorage.containsKey(key: 'encryptionKey');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(
        key: 'encryptionKey', value: base64UrlEncode(key));
  }

  String key = await secureStorage.read(key: 'encryptionKey') ?? '';

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (_) => User(username: '', password: '', hostUrl: '')),
    ChangeNotifierProvider(
      create: (_) => StorageManager(key),
    ),
    ChangeNotifierProvider(
      create: (_) => StyleManager(),
    ),
    ChangeNotifierProvider(
      create: (_) => SettingsManager(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageManager storage =
        Provider.of<StorageManager>(context, listen: false);
    StyleManager style = Provider.of<StyleManager>(context, listen: true);
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: false);
    storage.init(context).then((_) {
      settings.init(storage);
    });

    const Map<String, Widget> routes = {
      '/users': UserManagerPage(),
      '/settings': SettingsPage(),
      '/home/container': ContainerDetailsPage(),
      '/home': HomePage(),
      '/auth': AuthPage(),
      '/': Wrapper(),
    };

    return FutureBuilder<ThemeMode?>(
        future: style.getTheme(),
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Portarius',
            initialRoute: '/',
            //routes: _routes,
            onGenerateRoute: (settings) {
              String pageName = settings.name ?? '/';
              Widget routeWidget = routes[pageName] ?? const Wrapper();

              if (pageName == '/home/container') {
                return PageRouteBuilder(
                  settings: settings,
                  transitionDuration: const Duration(milliseconds: 250),
                  reverseTransitionDuration: const Duration(milliseconds: 150),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      routeWidget,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              }

              return PageRouteBuilder(
                settings:
                    settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
                transitionDuration: const Duration(milliseconds: 150),
                reverseTransitionDuration: const Duration(milliseconds: 150),
                pageBuilder: (_, __, ___) => routeWidget,
                transitionsBuilder: (_, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
              );
            },
            themeMode: snapshot.data,

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
        });
  }
}
