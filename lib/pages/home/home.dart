import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/settings_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    return SplitView(
      appBar: AppBar(
        title: const Text(
          'portarius',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      menuBuilder: (context) => Drawer(
        child: ColoredBox(
          color: context.theme.secondaryHeaderColor,
        ),
      ),
      contentBuilder: (context) => Container(
        color: Get.theme.backgroundColor,
        child: Center(
          child: Obx(
            () => Switch(
              value: settingsController.isDarkMode.value,
              onChanged: (value) => settingsController.toggleDarkMode(),
            ),
          ),
        ),
      ),
    );
  }
}
