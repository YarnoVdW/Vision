import 'package:flutter/material.dart';

class OnboardingWidget extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final Widget? button; // Optional button widget

  const OnboardingWidget({
    super.key,
    required this.title,
    required this.image,
    required this.description,
    this.button, // Optional button widget
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(image, width: 200),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: Text(description),
            ),
            if (button != null) ...[
              const SizedBox(height: 20),
              button!, // Display the button if provided
            ],
          ],
        ),
      ),
    );
  }
}
