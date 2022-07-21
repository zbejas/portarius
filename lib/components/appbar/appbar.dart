import 'package:flutter/material.dart';
import 'package:portarius/components/text_components/double_text.dart';
import 'package:portarius/models/portainer/endpoint.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/style.dart';
import 'package:provider/provider.dart';

class PortariusAppBar extends StatefulWidget {
  const PortariusAppBar({Key? key, this.endpoint, this.title = 'portarius'})
      : super(key: key);
  final Endpoint? endpoint;
  final String title;

  @override
  State<PortariusAppBar> createState() => PortariusAppBarState();
}

class PortariusAppBarState extends State<PortariusAppBar> {
  @override
  Widget build(BuildContext context) {
    StorageManager storage =
        Provider.of<StorageManager>(context, listen: false);
    StyleManager style = Provider.of<StyleManager>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    /// Sort snapshots by timestamp.
    List<EndpointSnapshot>? endpoints = widget.endpoint?.snapshots;

    if (endpoints != null) {
      endpoints.sort((a, b) => a.time!.compareTo(b.time!));
    }

    EndpointSnapshot? latestSnapshot = endpoints?.first;

    return SliverAppBar(
      pinned: true,
      primary: true,
      expandedHeight: widget.endpoint == null ? null : size.height * .225,
      title: widget.endpoint == null
          ? Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(fontWeight: FontWeight.bold),
            )
          : null,
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: const [],
      flexibleSpace: widget.endpoint == null
          ? null
          : FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 1.5,
              titlePadding: const EdgeInsets.only(bottom: 15),
              background: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Container(),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (latestSnapshot != null) ...[
                              DoubleText(
                                  value: latestSnapshot.runningContainerCount
                                      .toString(),
                                  label: 'Running'),
                              DoubleText(
                                  value: latestSnapshot.stoppedContainerCount
                                      .toString(),
                                  label: 'Stopped'),
                              DoubleText(
                                  value: latestSnapshot.imageCount.toString(),
                                  label: 'Images'),
                              DoubleText(
                                  value: latestSnapshot.volumeCount.toString(),
                                  label: 'Volumes'),
                            ],
                          ],
                        ),
                        Flexible(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              title: Text(
                'portarius',
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
