import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplitView extends StatelessWidget {
  final WidgetBuilder menuBuilder;
  final WidgetBuilder contentBuilder;
  final double breakpoint;
  final double menuWidth;
  // Scaffold options
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const SplitView({
    super.key,
    required this.menuBuilder,
    required this.contentBuilder,
    this.breakpoint = 700,
    this.menuWidth = 300,
    // Scaffold options
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Replace the line bellow if not using GetX (also remove the import)
    // final isBigScreen = MediaQuery.of(context).size.width > breakpoint;
    final isBigScreen = context.width > breakpoint;

    if (isBigScreen) {
      return Scaffold(
        // Apply manuWidth marhin to the appbar and bottom navigation bar
        appBar: appBar != null
            ? PreferredSize(
                preferredSize: appBar!.preferredSize,
                child: Row(
                  children: [
                    Container(
                      width: menuWidth,
                      // Replace the line bellow if not using GetX
                      // color: Theme.of(context).cardColor,
                      color: context.theme.cardColor,
                    ),
                    Expanded(child: appBar!),
                  ],
                ),
              )
            : null,
        bottomNavigationBar: bottomNavigationBar != null
            ? Container(
                margin: EdgeInsets.only(left: menuWidth),
                child: bottomNavigationBar,
              )
            : null,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: Row(
          children: [
            SizedBox(
              width: menuWidth,
              child: menuBuilder(context),
            ),
            Expanded(
              child: contentBuilder(context),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        drawer: menuBuilder(context),
        body: contentBuilder(context),
      );
    }
  }
}
