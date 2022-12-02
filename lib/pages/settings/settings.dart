import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/docker_controller.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageController storageController = Get.find();
    return WillPopScope(
      onWillPop: () {
        Get.offAllNamed('/home');
        return Future.value(false);
      },
      child: SplitView(
        appBar: AppBar(
          centerTitle: true,
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
        contentBuilder: (context) => Center(
          child: Obx(
            () => ListView(
              padding: const EdgeInsets.all(15),
              children: [
                Text(
                  'General',
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
                    subtitle: const Text('Toggle dark mode.'),
                    trailing: Switch(
                      value: controller.isDarkMode.value,
                      onChanged: (value) => controller.toggleDarkMode(),
                    ),
                  ),
                ),
                // Default sort order
                Card(
                  child: ListTile(
                    title: const Text(
                      'Default sort order',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Sets the default sort order.'),
                    trailing: DropdownButton<SortOptions>(
                      borderRadius: BorderRadius.circular(15),
                      value: DockerController().sortOptionFromString(
                        controller.sortOption.value,
                      ),
                      items: SortOptions.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.toString().split('.').last.capitalizeFirst!,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          controller.setSortOption(value!.toString()),
                    ),
                  ),
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
                    subtitle: const Text('Auto refresh in the home page.'),
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
                    enabled: controller.autoRefresh.value,
                    subtitle: const Text('Sets the auto refresh interval.'),
                    trailing: DropdownButton<int>(
                      value: controller.refreshInterval.value,
                      borderRadius: BorderRadius.circular(15),
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
                      onChanged: controller.autoRefresh.value
                          ? (value) => controller.setRefreshInterval(value!)
                          : null,
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
                    subtitle: const Text('Allow self-signed certificates.'),
                    trailing: Switch(
                      value: controller.allowAutoSignedCerts.value,
                      onChanged: (value) => controller.toggleAutoCert(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Information',
                  style: context.textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
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
                    subtitle: const Text('View portarius logs.'),
                    trailing: const Icon(Icons.list_alt),
                    onTap: () => Get.toNamed('/logs'),
                  ),
                ),
                // FAQ
                Card(
                  child: ListTile(
                    title: const Text(
                      'FAQ',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Frequently asked questions.'),
                    trailing: const Icon(Icons.question_answer),
                    onTap: () async {
                      const uri =
                          'https://github.com/zbejas/portarius/wiki/FAQ';
                      if (!await launchUrlString(
                        uri,
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw 'Could not launch $uri';
                      }
                    },
                  ),
                ),
                // Donate
                Card(
                  child: ListTile(
                    title: const Text(
                      'Donate',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    enabled: false,
                    subtitle:
                        const Text('Support the development of portarius'),
                    trailing: const Icon(Icons.favorite),
                    onTap: () {},
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
                    subtitle: const Text('App info and legal jibberish.'),
                    trailing: const Icon(Icons.info),
                    onTap: () => _showAbout(context),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Version info
                Text(
                  '${storageController.packageInfo.appName} v'
                  '${storageController.packageInfo.version}+${storageController.packageInfo.buildNumber}',
                  style: context.textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ],
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
      applicationName: 'portarius',
      applicationVersion: 'v${storageController.packageInfo.version}',
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
                    'cross-platform '
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
