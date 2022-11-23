import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portarius/components/widgets/split_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SplitView(
      appBar: AppBar(
        title: const Text('Portarius'),
      ),
      menuBuilder: (context) => Drawer(
        backgroundColor: context.theme.cardColor,
        child: ColoredBox(
          color: context.theme.cardColor,
        ),
      ),
      contentBuilder: (context) => Container(
        color: Get.theme.backgroundColor,
      ),
    );
  }
}
