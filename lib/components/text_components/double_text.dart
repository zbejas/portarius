import 'package:flutter/material.dart';

class DoubleText extends StatelessWidget {
  const DoubleText({Key? key, required this.value, required this.label})
      : super(key: key);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Theme.of(context).primaryColor)),
        Text(label, style: Theme.of(context).textTheme.bodyText2),
      ],
    );
  }
}
