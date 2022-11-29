import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitView(
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'portarius',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      menuBuilder: (context) => const PortariusDrawer(),
      contentBuilder: (context) => Container(
        color: context.theme.scaffoldBackgroundColor,
        child: Center(
          child: Obx(
            () => Padding(
              padding: const EdgeInsets.all(15),
              child: ListView(
                children: [
                  Text(
                    'Page refresh',
                    style: context.textTheme.headline3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Auto refresh toggle
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Auto refresh',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Toggles the auto refresh.'),
                      trailing: Switch(
                        value: controller.autoRefresh.value,
                        onChanged: (value) => controller.toggleAutoRefresh(),
                      ),
                    ),
                  ),
                  // Auto refresh interval
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Auto refresh interval',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Sets the auto refresh interval.'),
                      trailing: DropdownButton<int>(
                        value: controller.refreshInterval.value,
                        items: const [
                          DropdownMenuItem(
                            value: 1,
                            child: Text('1 second'),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text('3 seconds'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5 seconds'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10 seconds'),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 seconds'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 seconds'),
                          ),
                        ],
                        onChanged: (value) =>
                            controller.setRefreshInterval(value!),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Security',
                    style: context.textTheme.headline3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Biometrics
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Biometrics',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Toggle biometric authentication.'),
                      trailing: Switch(
                        value: controller.isAuthEnabled.value,
                        onChanged: (value) async {
                          await controller.toggleAuthEnabled();
                        },
                      ),
                    ),
                  ),
                  // Ssl verification
                  Card(
                    child: ListTile(
                      title: const Text(
                        'SSL verification',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Toggle SSL verification'),
                      trailing: Switch(
                        value: controller.isSslVerificationEnabled.value,
                        onChanged: (value) =>
                            controller.toggleSslVerificationEnabled(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Application',
                    style: context.textTheme.headline3,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Dark mode
                  Card(
                    child: ListTile(
                      title: const Text(
                        'Dark mode',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Toggle dark mode'),
                      trailing: Switch(
                        value: controller.isDarkMode.value,
                        onChanged: (value) => controller.toggleDarkMode(),
                      ),
                    ),
                  ),
                  // About
                  Card(
                    child: ListTile(
                      title: const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('About portarius'),
                      trailing: const Icon(Icons.info),
                      onTap: () => _showAbout(context),
                    ),
                  ),
                  // View logs
                  Card(
                    child: ListTile(
                      title: const Text(
                        'View logs',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      enabled: false,
                      subtitle: const Text('View portarius logs'),
                      trailing: const Icon(Icons.list_alt),
                      onTap: () => Get.toNamed('/settings/logs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final StorageController storageController = Get.find();
    showAboutDialog(
      context: context,
      applicationName: 'Portarius',
      applicationVersion: storageController.packageInfo.version,
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
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Portarius',
                style: context.textTheme.bodyText1!
                    .copyWith(color: context.theme.primaryColor),
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
                style: context.textTheme.bodyText1,
              ),
              TextSpan(
                text: '\n\nPortarius is developed and maintained by ',
                style: context.textTheme.bodyMedium,
              ),
              TextSpan(
                text: 'Zbejas.',
                style: context.textTheme.bodyMedium!
                    .copyWith(color: context.theme.primaryColor),
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
                style: context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
