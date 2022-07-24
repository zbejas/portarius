import 'package:flutter/material.dart';
import 'package:portarius/components/cards/setting_tile.dart';
import 'package:portarius/services/remote.dart';
import 'package:portarius/services/storage.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../components/appbar/appbar.dart';
import '../../components/drawer/drawer.dart';
import '../../models/portainer/token.dart';
import '../../models/portainer/user.dart';

class UserManagerPage extends StatefulWidget {
  const UserManagerPage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserManagerPage> createState() => _UserManagerPageState();
}

class _UserManagerPageState extends State<UserManagerPage> {
  final ScrollController _scrollController = ScrollController();
  bool _areUsersLoaded = false;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    User user = Provider.of<User>(context, listen: true);

    List<User> userList = storage.savedUsers;
    bool? fromAuthPage =
        ModalRoute.of(context)?.settings.arguments as bool? ?? false;

    if (!_areUsersLoaded) {
      storage.refreshUsers().then((value) => setState(() {
            _areUsersLoaded = true;
          }));
    }

    return WillPopScope(
      onWillPop: () async {
        if (fromAuthPage) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add User',
          onPressed: () async {
            await _showAddUserDialog(storage);
          },
          child: const Icon(Icons.add),
        ),
        drawer: fromAuthPage
            ? null
            : const Padding(
                padding: EdgeInsets.only(
                  top: 45,
                  bottom: 10,
                ),
                child: PortariusDrawer(
                  pageRoute: '/users',
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
                            left: 20,
                            top: 20,
                          ),
                          child: Text(
                            'Users',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ),
                      ListBody(
                        children: [
                          ...userList.map((u) {
                            return Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: PortariusSettingTile(
                                enabled: fromAuthPage ? true : user != u,
                                title: u.username,
                                subtitle: u.hostUrl,
                                trailing: user != u
                                    ? const Icon(Icons.person)
                                    : const Icon(
                                        Icons.check,
                                        size: 30,
                                      ),
                                onTap: () async {
                                  await _showUserDialog(
                                      user, u, storage, fromAuthPage);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _validateUser(String username, String hostUrl, String password,
      StorageManager storage) async {
    Token? token =
        await RemoteService().authPortainer(username, password, hostUrl);

    if (token == null && mounted) {
      ToastContext().init(context);
      Toast.show(
        'Invalid credentials.',
      );
      return null;
    }

    if (hostUrl.endsWith('/')) {
      hostUrl = hostUrl.substring(0, hostUrl.length - 1);
    }

    if (token != null) {
      User user = User(
        username: username,
        hostUrl: hostUrl,
        password: password,
        token: token,
      );
      await storage.addUserToList(user);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  _showUserDialog(User loggedUser, User clickedUser, StorageManager storage,
      bool fromAuthPage) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(clickedUser.username),
          content: Text(
            'Viewing user\n${clickedUser.username}@${clickedUser.hostUrl}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () async {
                loggedUser.setNewUser(clickedUser);
                await storage.saveUser(clickedUser);
                if (mounted) {
                  storage.initUser(context);
                  if (fromAuthPage) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/auth', (route) => false);
                  } else {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete User'),
                      content: const Text(
                        'Are you sure you want to delete this user?',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () async {
                            await storage.removeUserFromList(clickedUser);
                            if (mounted) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  _showAddUserDialog(StorageManager storage) {
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController hostUrlController = TextEditingController();

    Size size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: Form(
            child: Wrap(
              children: [
                TextFormField(
                  controller: hostUrlController,
                  scrollPadding: EdgeInsets.all(size.height * .15),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Host URL',
                    hintText: 'https://portainer.example.com',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a host URL';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                  width: size.width,
                ),
                TextFormField(
                  controller: usernameController,
                  scrollPadding: EdgeInsets.all(size.height * .1),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'admin',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                  width: size.width,
                ),
                TextFormField(
                  controller: passwordController,
                  scrollPadding: EdgeInsets.all(size.height * .12),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    _validateUser(
                        usernameController.text,
                        hostUrlController.text,
                        passwordController.text,
                        storage);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _validateUser(usernameController.text, hostUrlController.text,
                    passwordController.text, storage);
              },
            ),
          ],
        );
      },
    );
  }
}
