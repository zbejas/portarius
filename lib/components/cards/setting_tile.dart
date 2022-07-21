import 'package:flutter/material.dart';
import 'package:portarius/services/storage.dart';
import 'package:provider/provider.dart';

class PortariusSettingTile extends StatefulWidget {
  const PortariusSettingTile(
      {Key? key,
      required this.onTap,
      required this.title,
      required this.subtitle,
      required this.trailing,
      this.enabled = true})
      : super(key: key);
  final Function onTap;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool enabled;

  @override
  State<PortariusSettingTile> createState() => _PortariusSettingTileState();
}

class _PortariusSettingTileState extends State<PortariusSettingTile> {
  @override
  Widget build(BuildContext context) {
    StorageManager storage =
        Provider.of<StorageManager>(context, listen: false);
    return Card(
      margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: InkWell(
        onTap: !widget.enabled
            ? null
            : () {
                widget.onTap();
              },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            enabled: widget.enabled,
            title: Text(widget.title),
            subtitle: Text(widget.subtitle),
            trailing: widget.trailing,
          ),
        ),
      ),
    );
  }
}
