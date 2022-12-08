import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/services/controllers/storage_controller.dart';

class BackupAndRestorePage extends GetView<StorageController> {
  const BackupAndRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Text(
                'settings_backup_restore_title'.tr,
                style: context.textTheme.headline3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 60,
              ),
              Text(
                'settings_backup_restore_backup_content'.tr.tr,
                style: context.textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.exportData();
                      },
                      child: Text('settings_backup_restore_backup_button'.tr),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.importData();
                      },
                      child: Text('settings_backup_restore_restore_button'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
