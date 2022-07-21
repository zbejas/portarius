import 'package:flutter/material.dart';
import 'package:portarius/models/portainer/user.dart';

class BigBlueButton extends StatefulWidget {
  const BigBlueButton(
      {Key? key,
      required this.formKey,
      required this.onClick,
      required this.buttonTitle})
      : super(key: key);

  /// Form key
  /// This key is used to validate the form
  final GlobalKey<FormState> formKey;

  /// On click function to be called when button is pressed
  /// This function is called with the [User] object as parameter
  /// If the form is invalid, the function is not called
  final void Function() onClick;

  /// Text to be displayed on the button
  final String buttonTitle;

  @override
  State<BigBlueButton> createState() => _BigBlueButtonState();
}

class _BigBlueButtonState extends State<BigBlueButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (widget.formKey.currentState!.validate()) {
          widget.onClick();
        }
      },
      child: Text(
        widget.buttonTitle,
        style: Theme.of(context).textTheme.button,
      ),
    );
  }
}
