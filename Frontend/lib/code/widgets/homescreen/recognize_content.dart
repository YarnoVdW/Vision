import 'package:flutter/material.dart';

class RecognizeContent extends StatelessWidget {
  final String? text;

  const RecognizeContent({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 16.0,
          ),
          Text(
            text!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
