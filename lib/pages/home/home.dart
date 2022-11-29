import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/drawer.dart';
import 'package:portarius/components/widgets/split_view.dart';
import 'package:portarius/services/controllers/settings_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitView(
      appBar: AppBar(
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
      contentBuilder: (context) => Container(
        color: context.theme.scaffoldBackgroundColor,
        child: Center(
          child: Text(
            'Home',
            style: context.textTheme.headline3,
          ),
        ),
      ),
    );
  }
}
