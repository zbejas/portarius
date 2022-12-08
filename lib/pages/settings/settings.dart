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
                  'settings_title_general'.tr,
                  style: context.textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Dark mode
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_dark_mode'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_dark_mode_subtitle'.tr),
                    trailing: Switch(
                      value: controller.isDarkMode.value,
                      onChanged: (value) => controller.toggleDarkMode(),
                    ),
                  ),
                ),
                // Language
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_language'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_language_subtitle'.tr),
                    trailing: DropdownButton<Locale>(
                      borderRadius: BorderRadius.circular(15),
                      value: controller.locale.value,
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en', 'US'),
                          child: Text('English US'),
                        ),
                        DropdownMenuItem(
                          value: Locale('sl'),
                          child: Text('Slovenian'),
                        ),
                      ],
                      onChanged: (value) => Get.defaultDialog(
                        title: 'dialog_settings_language_title'.tr,
                        content: Text(
                          'dialog_settings_language_content'.trParams(
                            {
                              'language':
                                  '${value!.languageCode}${value.countryCode != null ? '_${value.countryCode}' : ''}',
                            },
                          ),
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('dialog_cancel'.tr),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.setLocale(value);
                              Get.back();
                            },
                            child: Text('dialog_ok'.tr),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(
                  endIndent: 20,
                  indent: 20,
                ),
                // Default sort order
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_sorting'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_sorting_subtitle'.tr),
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
                    title: Text(
                      'settings_auto_refresh'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_auto_refresh_subtitle'.tr),
                    trailing: Switch(
                      value: controller.autoRefresh.value,
                      onChanged: (value) => controller.toggleAutoRefresh(),
                    ),
                  ),
                ),
                // Auto refresh interval
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_auto_refresh_interval'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    enabled: controller.autoRefresh.value,
                    subtitle:
                        Text('settings_auto_refresh_interval_subtitle'.tr),
                    trailing: DropdownButton<int>(
                      value: controller.refreshInterval.value,
                      borderRadius: BorderRadius.circular(15),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 ${'second'.tr}'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 ${'seconds'.tr}'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5 ${'seconds'.tr}'),
                        ),
                        DropdownMenuItem(
                          value: 10,
                          child: Text('10 ${'seconds'.tr}'),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text('15 ${'seconds'.tr}'),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text('30 ${'seconds'.tr}'),
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
                  'settings_title_security'.tr,
                  style: context.textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                // Biometrics
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_biometrics'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_biometrics_subtitle'.tr),
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
                    title: Text(
                      'settings_ssl_verification'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_ssl_verification_subtitle'.tr),
                    trailing: Switch(
                      value: controller.allowAutoSignedCerts.value,
                      onChanged: (value) => controller.toggleAutoCert(),
                    ),
                  ),
                ),
                // Paranoid mode
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_paranoid_mode'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_paranoid_mode_subtitle'.tr),
                    trailing: Switch(
                      value: controller.paranoidMode.value,
                      onChanged: (value) => controller.toggleParanoidMode(),
                    ),
                  ),
                ),
                // Backup
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_backup_restore'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_backup_restore_subtitle'.tr),
                    trailing: const Icon(Icons.settings_backup_restore),
                    onTap: () => Get.toNamed('/settings/backup_restore'),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'settings_title_information'.tr,
                  style: context.textTheme.headline3,
                ),
                const SizedBox(
                  height: 10,
                ),
                // View logs
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_view_logs'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    enabled: false,
                    subtitle: Text('settings_view_logs_subtitle'.tr),
                    trailing: const Icon(Icons.list_alt),
                    onTap: () => Get.toNamed('/logs'),
                  ),
                ),
                // FAQ
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_faq'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_faq_subtitle'.tr),
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
                const Divider(
                  endIndent: 20,
                  indent: 20,
                ),
                // Donate
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_donate'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    enabled: false,
                    subtitle: Text('settings_donate_subtitle'.tr),
                    trailing: const Icon(Icons.favorite),
                    onTap: () {},
                  ),
                ),
                // About
                Card(
                  child: ListTile(
                    title: Text(
                      'settings_about'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('settings_about_subtitle'.tr),
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
