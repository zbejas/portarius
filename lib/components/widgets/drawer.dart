import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/services/controllers/drawer_controller.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class PortariusDrawer extends GetView<PortariusDrawerController> {
  const PortariusDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageController storage = Get.find();

    return Drawer(
      backgroundColor: context.theme.canvasColor,
      child: Obx(
        () => ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: context.theme.canvasColor,
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
                    'v${storage.packageInfo.version}',
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
              selected: controller.pickedPage.value == '/',
              onTap: () {
                if (controller.pickedPage.value == '/') {
                  return;
                }

                controller.setPage('/');
                Get.offAllNamed('/');
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
              enabled: false,
              onTap: () {},
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
              enabled: false,
              onTap: () {},
              selected: controller.pickedPage.value == '/settings',
            ),
            // todo: Dropdown for endpoint selection
          ],
        ),
      ),
    );
  }
}
