import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thelab/code/widgets/settings/menu_button.dart';

class TranscriptionPage extends StatelessWidget {
  final String content;
  final String title;

  const TranscriptionPage(
      {super.key, required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
        leading: CustomIconButton(
          icon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          color:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SingleChildScrollView(
                child: Text(content),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
