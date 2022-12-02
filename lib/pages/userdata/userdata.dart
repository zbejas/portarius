import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  // MIght later be expanded to add more options
  @override
  Widget build(BuildContext context) {
    final UserDataController userDataController = Get.find();
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.toNamed('/userdata/add_server');
          },
          child: const Icon(Icons.add),
        ),
        menuBuilder: (context) => const PortariusDrawer(),
        contentBuilder: (context) => Obx(
          () => Center(
            child: userDataController.serverList.isEmpty
                ? Text(
                    'Add a server to get started.',
                    style: context.textTheme.headline5,
                    textAlign: TextAlign.center,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                    ),
                    itemCount: userDataController.serverList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: userDataController.currentServer != null &&
                                userDataController.currentServer!.name ==
                                    userDataController.serverList[index].name
                            ? 3
                            : 0,
                        child: InkWell(
                          onTap: () async {
                            final bool result =
                                userDataController.setCurrentServer(
                              userDataController.serverList[index],
                            );

                            if (!result) {
                              return;
                            }

                            setState(() {});

                            Get.snackbar(
                              'Server changed',
                              'Server changed to ${userDataController.currentServer!.name}',
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: ListTile(
                            title:
                                Text(userDataController.serverList[index].name),
                            subtitle: Text(
                              userDataController.serverList[index].baseUrl,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    // dialog confirming deletion
                                    Get.defaultDialog(
                                      title: 'Are you sure?',
                                      middleText:
                                          'This action cannot be undone.',
                                      textConfirm: 'Delete',
                                      textCancel: 'Cancel',
                                      onConfirm: () {
                                        // if server was current server, set current server to null
                                        if (userDataController.currentServer !=
                                                null &&
                                            userDataController.currentServer! ==
                                                userDataController
                                                    .serverList[index]) {
                                          userDataController.currentServer =
                                              null;
                                        }

                                        userDataController.removeServer(
                                          userDataController.serverList[index],
                                        );

                                        Get.back();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
