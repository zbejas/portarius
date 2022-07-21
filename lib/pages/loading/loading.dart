import 'package:flutter/material.dart';
import 'package:portarius/services/storage.dart';
import 'package:provider/provider.dart';

import '../../utils/settings.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _timeout = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    SettingsManager settings =
        Provider.of<SettingsManager>(context, listen: true);

    if (!_timeout) {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _timeout = true;
          });
        }
      });
    }

    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 45,
              child: Container(
                  margin: EdgeInsets.only(top: size.height * 0.05),
                  child:
                      Image.asset('assets/icons/icon.png', fit: BoxFit.fill)),
            ),
            Flexible(
              flex: 15,
              child: Container(),
            ),
            Flexible(
              flex: 40,
              child: _timeout
                  ? Center(
                      child: TextButton(
                        onPressed: () async {
                          setState(() {
                            _timeout = false;
                          });
                          await storage.init(context);
                          await settings.init(storage);
                        },
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 12.5),
                        Text('Loading...'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
