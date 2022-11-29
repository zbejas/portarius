import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/userdata_controller.dart';

class UserDataPage extends GetView<UserDataController> {
  const UserDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitView(
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
        child: Text(
          'User Data',
          style: context.textTheme.headline3,
        ),
      ),
    );
  }
}
