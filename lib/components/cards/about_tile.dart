import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:portarius/components/cards/setting_tile.dart';
import 'package:portarius/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// A tile that displays a aboutDialog that contains information about the app,
/// the app's author, and the app's source code.
class PortariusAboutTile extends StatelessWidget {
  const PortariusAboutTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageManager storage =
        Provider.of<StorageManager>(context, listen: false);
    return PortariusSettingTile(
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Portarius',
          applicationVersion: storage.packageInfo.version,
          routeSettings: const RouteSettings(
            name: '/about',
          ),
          applicationIcon: Image.asset(
            'assets/icons/icon.png',
            width: 100,
          ),
          applicationLegalese: '© ${DateTime.now().year} Zbejas',
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: 'Portarius',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Theme.of(context).primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const uri = 'https://github.com/zbejas/portarius';
                      if (!await launchUrlString(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw 'Could not launch $uri';
                      }
                    },
                ),
                TextSpan(
                  text: ' is a free, open-source, '
                      'cross-platform mobile '
                      'application that allows you to '
                      'manage your Portainer sessions.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                TextSpan(
                  text: '\n\nPortarius is developed and maintained by ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextSpan(
                  text: 'Zbejas.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).primaryColor),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      const uri = 'https://github.com/zbejas/';
                      if (!await launchUrlString(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw 'Could not launch $uri';
                      }
                    },
                ),
                TextSpan(
                  text:
                      '\n\nThis app is in no way or form related to the official Portainer project.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]),
            ),
          ],
        );
      },
      title: 'About Portarius',
      subtitle: 'App info and legal jibberish',
      trailing: const Icon(Icons.info),
    );
  }
}
