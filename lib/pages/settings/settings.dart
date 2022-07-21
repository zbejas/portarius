import 'package:flutter/material.dart';
import 'package:portarius/components/cards/about_tile.dart';
import 'package:portarius/services/local_auth.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/settings.dart';
import 'package:provider/provider.dart';

import '../../components/appbar/appbar.dart';
import '../../components/drawer/drawer.dart';
import '../../models/portainer/user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: true);
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    User user = Provider.of<User>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(
          '/home',
        );
        return true;
      },
      child: Scaffold(
        drawer: const Padding(
            padding: EdgeInsets.only(
              top: 45,
              bottom: 10,
            ),
            child: PortariusDrawer(
              pageRoute: '/settings',
            )),
        body: CustomScrollView(
          controller: _scrollController,
          shrinkWrap: true,
          slivers: [
            const PortariusAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            top: 20,
                          ),
                          child: Text(
                            'Page Refresh',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ),
                      Card(
                        margin:
                            const EdgeInsets.only(left: 15, right: 15, top: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            title: const Text('Auto Refresh'),
                            subtitle: const Text('Toggles the auto refresh.'),
                            trailing: Switch(
                              value: settings.autoRefresh,
                              onChanged: (value) async {
                                await storage.saveAutoRefresh(value);
                                await settings.refreshSettings(storage);
                              },
                            ),
                          ),
                        ),
                      ),
                      Card(
                        margin:
                            const EdgeInsets.only(left: 15, right: 15, top: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ListTile(
                            enabled: settings.autoRefresh,
                            title: const Text('Auto Refresh Interval'),
                            subtitle: const Text(
                                'Sets the auto refresh interval in seconds.'),
                            trailing: DropdownButton(
                              value: settings.autoRefreshInterval,
                              items: [
                                ...[1, 3, 5, 10, 15, 30]
                                    .map(
                                      (interval) => DropdownMenuItem(
                                        value: interval,
                                        child: Text(
                                          '${interval}s',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ],
                              onChanged: !settings.autoRefresh
                                  ? null
                                  : (int? value) {
                                      storage
                                          .saveAutoRefreshInterval(value ?? 10);
                                      settings.refreshSettings(storage);
                                    },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 20,
                      ),
                      child: Text(
                        'App Lock',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: const Text('Use biometric authentication'),
                        subtitle:
                            const Text('Toggles biometric authentication.'),
                        trailing: Switch(
                          value: settings.biometricEnabled,
                          onChanged: (value) async {
                            if (await LocalAuthManager.deviceSupported()) {
                              await storage.saveBiometric(value);
                              await settings.refreshSettings(storage);
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Biometric authentication'),
                                      content: const Text(
                                          'Your device does not support biometric authentication.'
                                          '\n\nThis may be because you have not enabled it in your device settings.'),
                                      actions: [
                                        TextButton(
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 20,
                      ),
                      child: Text(
                        'About',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  const PortariusAboutTile(),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
