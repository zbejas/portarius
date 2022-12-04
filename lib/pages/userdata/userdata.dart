import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/settings_controller.dart';
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
    final SettingsController settingsController = Get.find();
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
                    'userdata_no_server'.tr,
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
                              'snackbar_userdata_server_changed_title'.tr,
                              'snackbar_userdata_server_changed_content'
                                  .trParams(
                                {
                                  'name':
                                      userDataController.currentServer!.name,
                                },
                              ),
                              snackPosition: SnackPosition.TOP,
                              duration: const Duration(seconds: 1),
                            );
                          },
                          child: ListTile(
                            title: Text(
                              userDataController.serverList[index].name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              settingsController.paranoidMode.value
                                  ? _getObfuscated(
                                      userDataController
                                          .serverList[index].baseUrl,
                                      userDataController
                                          .serverList[index].token,
                                    )
                                  : userDataController
                                      .serverList[index].baseUrl,
                              overflow: TextOverflow.ellipsis,
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
                                      title:
                                          'dialog_userdata_server_delete_title'
                                              .tr,
                                      middleText:
                                          'dialog_userdata_server_delete_content'
                                              .trParams(
                                        {
                                          'name': userDataController
                                              .serverList[index].name,
                                        },
                                      ),
                                      textConfirm: 'dialog_confirm_delete'.tr,
                                      textCancel: 'dialog_cancel'.tr,
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

  String _getObfuscated(String text, String encodeKey) {
    // return a random char from the list
    final String charList = '/\\#\$%^&*+{}?';
    // generate a value from the values of the chars in the string
    final int endoceValue = encodeKey.codeUnits.reduce((a, b) => a + b);

    // have randomness set by the day so that it's consistent
    // but not the same every time
    final Random random = Random(DateTime.now().day * endoceValue);

    return text
        .split('')
        .map((e) => charList[random.nextInt(charList.length)])
        .join();
  }
}
