import 'package:flutter/material.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/services/remote.dart';
import 'package:portarius/utils/settings.dart';
import 'package:portarius/utils/style.dart';
import 'package:provider/provider.dart';

import '../../../models/portainer/user.dart';
import '../../../services/storage.dart';

class PortariusDrawer extends StatefulWidget {
  const PortariusDrawer({Key? key, required this.pageRoute}) : super(key: key);
  final String pageRoute;

  @override
  State<PortariusDrawer> createState() => _PortariusDrawerState();
}

class _PortariusDrawerState extends State<PortariusDrawer> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: false);
    StorageManager storage =
        Provider.of<StorageManager>(context, listen: false);
    StyleManager style = Provider.of<StyleManager>(context, listen: false);
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: true);
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
      child: Drawer(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 20, top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        'portarius',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      tooltip: 'Change Theme',
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? const Icon(Icons.light_mode)
                          : const Icon(Icons.dark_mode),
                      onPressed: () {
                        style.setTheme(
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.light
                                : ThemeMode.dark);
                      },
                    ),
                  ),
                ],
              ),
              const Flexible(
                flex: 1,
                child: Divider(
                  thickness: 0.75,
                  indent: 20,
                ),
              ),
              Flexible(
                flex: 15,
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        enabled: true,
                        selected: widget.pageRoute == '/home',
                        title: const Text('Home'),
                        subtitle: const Text('Home Page'),
                        trailing: const Icon(
                          Icons.home,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                      ),
                      ListTile(
                        title: const Text('User management'),
                        subtitle: const Text('Manage your saved userdata'),
                        trailing: const Icon(Icons.person),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/users');
                        },
                      ),
                      ListTile(
                        enabled: true,
                        selected: widget.pageRoute == '/settings',
                        title: const Text('Settings'),
                        subtitle: const Text('Adjust your settings'),
                        trailing: const Icon(
                          Icons.settings,
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context)
                              .pushReplacementNamed('/settings');
                        },
                      ),
                      ListTile(
                        enabled: true,
                        title: const Text('Endpoints'),
                        subtitle: const Text('Select your endpoint'),
                        trailing: FutureBuilder<List<Endpoint>>(
                          future: RemoteService().getEndpoints(user),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Endpoint? pickedEndpoint =
                                  snapshot.data!.firstWhere(
                                (endpoint) =>
                                    endpoint.id == settings.selectedEndpointId,
                              );

                              if (snapshot.data!.isEmpty) {
                                return const Text('No endpoints');
                              } else if (snapshot.data!.length == 1) {
                                return Text(pickedEndpoint.name ?? 'default');
                              } else if (snapshot.data != null) {
                                return DropdownButton(
                                  items: [
                                    ...snapshot.data!
                                        .map(
                                          (endpoint) => DropdownMenuItem(
                                            value: endpoint.id,
                                            child: Text(
                                              endpoint.name ?? 'Unknown',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  value: pickedEndpoint.name,
                                  onChanged: (value) {
                                    settings.selectedEndpointId = value as int;
                                    storage.saveEndpointId(value);
                                  },
                                );
                              } else {
                                return const Text('No endpoints');
                              }
                            } else if (snapshot.hasError) {
                              return const Text('Error');
                            } else {
                              return const Text('Loading');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: ListTile(
                    textColor: Theme.of(context).errorColor,
                    iconColor: Theme.of(context).errorColor,
                    title: const Text('Log Out'),
                    trailing: const Icon(
                      Icons.logout,
                    ),
                    onTap: () async {
                      await storage.clearEndpointId();
                      // ignore: use_build_context_synchronously
                      await user.logOutUser(context);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  ),
                ),
              ),
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Text('Portarius v${storage.packageInfo.version}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
