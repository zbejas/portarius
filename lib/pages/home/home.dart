import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portarius/components/appbar/appbar.dart';
import 'package:portarius/components/drawer/drawer.dart';
import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/services/remote.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/settings.dart';
import 'package:portarius/utils/style.dart';
import 'package:provider/provider.dart';

import '../../components/lists/container_grid_list.dart';
import '../../models/portainer/endpoint.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Endpoint> _endpoints = [];
  Endpoint? _selectedEndpoint;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: true);
    // ignore: unused_local_variable
    StyleManager style = Provider.of<StyleManager>(context, listen: true);
    Size size = MediaQuery.of(context).size;

    /// Get the endpoints from the API and store them in the [_endpoints] list.
    /// Then select the first endpoint in the list as the selected endpoint.
    if (_selectedEndpoint == null || _endpoints.isEmpty) {
      RemoteService().getEndpoints(user).then((endpoints) {
        if (mounted) {
          setState(() {
            /// Select the first endpoint.
            if (endpoints.isNotEmpty) {
              if (settings.selectedEndpointId == null) {
                _selectedEndpoint = endpoints.first;
                settings.selectedEndpointId = endpoints.first.id;
                storage.saveEndpointId(endpoints.first.id ?? 1);
              } else {
                _selectedEndpoint = endpoints.firstWhere(
                  (endpoint) => endpoint.id == settings.selectedEndpointId,
                  orElse: () => endpoints.first,
                );
              }
            }
            _endpoints = endpoints;
          });
        }
      });
    }

    return WillPopScope(
      onWillPop: () async {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          if (_scrollController.offset == 0) {
            bool result = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to exit the application?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            );
            if (result) {
              SystemNavigator.pop();
            }
          } else {
            return false;
          }
        }
        return false;
      },
      child: Scaffold(
        drawer: const Padding(
            padding: EdgeInsets.only(
              top: 45,
              bottom: 10,
            ),
            child: PortariusDrawer(
              pageRoute: '/home',
            )),
        body: RefreshIndicator(
          onRefresh: () async {
            _endpoints = await RemoteService().getEndpoints(user);
            setState(() {
              _selectedEndpoint = null;
            });
          },
          edgeOffset: size.height * .25,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              PortariusAppBar(endpoint: _selectedEndpoint),
              _selectedEndpoint == null
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: size.height * 0.05,
                      ),
                      sliver: ContainerGrid(
                        endpoint: _selectedEndpoint!,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
