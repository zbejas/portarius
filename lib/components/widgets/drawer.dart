import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/services/controllers/drawer_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

class PortariusDrawer extends GetView<PortariusDrawerController> {
  const PortariusDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageController storage = Get.find();
    final ScrollController scrollController = ScrollController();
    final UserDataController userDataController = Get.find();

    return Drawer(
      backgroundColor: context.theme.canvasColor,
      child: Obx(
        () => Column(
          children: [
            Flexible(
              flex: 10,
              child: ListView(
                controller: scrollController,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      top: context.height * 0.1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'portarius',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: context.theme.textTheme.headline1!.color,
                          ),
                        ),
                        // version
                        Text(
                          userDataController.currentServer == null
                              ? 'v${storage.packageInfo.version}'
                              : userDataController.currentServer!.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.theme.textTheme.headline1!.color,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                          width: 50,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Home page'),
                    trailing: const Icon(Icons.home),
                    selected: controller.pickedPage.value == '/home',
                    onTap: () {
                      if (controller.pickedPage.value == '/home') {
                        return;
                      }
                      Get.back();
                      controller.setPage('/home');
                      Get.offAndToNamed('/home');
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'User Data',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Modify stored user data'),
                    trailing: const Icon(Icons.person),
                    onTap: () {
                      if (controller.pickedPage.value == '/userdata') {
                        return;
                      }
                      Get.back();
                      controller.setPage('/userdata');
                      Get.offAndToNamed('/userdata');
                    },
                    selected: controller.pickedPage.value == '/userdata',
                  ),
                  ListTile(
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text('Modify app settings'),
                    trailing: const Icon(Icons.settings),
                    onTap: () async {
                      if (controller.pickedPage.value == '/settings') {
                        return;
                      }
                      Get.back();
                      controller.setPage('/settings');
                      Get.offAndToNamed('/settings');
                    },
                    selected: controller.pickedPage.value == '/settings',
                  ),
                  // todo: Dropdown for endpoint selection
                  if (userDataController.currentServer != null)
                    ListTile(
                      title: const Text(
                        'Endpoint',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text('Select your endpoint'),
                      trailing: DropdownButton<String>(
                        value: userDataController.currentServer!.endpoint,
                        items: userDataController.currentServerEndpoints
                            .map(
                              (e) => DropdownMenuItem<String>(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) async {
                          if (value == null) {
                            return;
                          }
                          userDataController.setNewCurrentServerEndpoint(value);
                        },
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
