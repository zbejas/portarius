import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:portarius/components/buttons/big_blue_button.dart';
import 'package:portarius/models/portainer/user.dart';
import 'package:portarius/services/storage.dart';
import 'package:portarius/utils/style.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../models/portainer/token.dart';

/// [AuthPage] for Portarius.
/// This page is used to authenticate with Portainer.
/// It will display a form to enter the host url, username and password.
/// Once the user has entered the credentials, it will send a request to Portainer
/// to authenticate. If the credentials are correct, it will store the token in
/// the local storage.
/// The token will be used to access the Portainer API.
class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _hostUrlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Open the local storage.
    _loadDataFromStorage();
  }

  @override
  void dispose() {
    super.dispose();
    _hostUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);
    StorageManager storage = Provider.of<StorageManager>(context, listen: true);
    StyleManager style = Provider.of<StyleManager>(context, listen: true);
    Size size = MediaQuery.of(context).size;

    if (user.token != null && mounted) {
      Future.delayed(const Duration(milliseconds: 150), () {
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 4,
                child: Container(
                    margin: EdgeInsets.only(top: size.height * 0.05),
                    child:
                        Image.asset('assets/icons/icon.png', fit: BoxFit.fill)),
              ),
              Flexible(
                flex: 5,
                child: Center(
                  child: SizedBox(
                    width: size.width * 0.85 > 500 ? 500 : size.width * 0.85,
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Form(
                          autovalidateMode: AutovalidateMode.disabled,
                          key: _formKey,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Authentication',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 15,
                                width: size.width,
                              ),
                              TextFormField(
                                controller: _hostUrlController,
                                scrollPadding:
                                    EdgeInsets.all(size.height * .15),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.url,
                                decoration: const InputDecoration(
                                  labelText: 'Host URL',
                                  hintText: 'https://portainer.example.com',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a host URL';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                                width: size.width,
                              ),
                              TextFormField(
                                controller: _usernameController,
                                scrollPadding: EdgeInsets.all(size.height * .1),
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'admin',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a username';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 10,
                                width: size.width,
                              ),
                              TextFormField(
                                controller: _passwordController,
                                scrollPadding:
                                    EdgeInsets.all(size.height * .12),
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                onEditingComplete: () =>
                                    _authenticateButton(user, storage),
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 15,
                                width: size.width,
                              ),
                              if (_isLoading) ...[
                                const CircularProgressIndicator(),
                              ] else ...[
                                BigBlueButton(
                                  formKey: _formKey,
                                  onClick: () =>
                                      _authenticateButton(user, storage),
                                  buttonTitle: 'Log In',
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.group),
                      onPressed: () {
                        Navigator.pushNamed(context, '/users', arguments: true);
                      },
                    ),
                    IconButton(
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? const Icon(Icons.light_mode)
                          : const Icon(Icons.dark_mode),
                      onPressed: () {
                        style.setTheme(
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.light
                                : ThemeMode.dark);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _loadDataFromStorage() async {
    setState(() {
      _isLoading = true;
    });

    // Load the data from the local storage.
    var box = await Hive.openBox('portainer');

    User? userData = box.get('user');

    setState(() {
      _hostUrlController.text = userData?.hostUrl ?? '';
      _usernameController.text = userData?.username ?? '';
      _passwordController.text = userData?.password ?? '';

      _isLoading = false;
    });
  }

  _authenticateButton(User user, StorageManager storage) async {
    setState(() {
      _isLoading = true;
    });

    user.username = _usernameController.text;
    user.password = _passwordController.text;
    user.hostUrl = _hostUrlController.text;

    Token? token = await user.authPortainer();

    if (token != null) {
      await storage.addUserToList(user);
      await storage.saveUser(user);
      user.setToken(token);
    } else {
      _showToast('Authentication failed.');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _showToast(String message) {
    ToastContext().init(context);
    Toast.show(message, duration: Toast.lengthLong);
  }
}
