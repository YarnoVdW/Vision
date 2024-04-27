import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class TranscriptionListItem extends StatelessWidget {
  final File file;
  final Future<void> Function() onTap;
  final Future<void> Function() onLongPress;
  final Future<void> Function() onHorizontalDragEnd;

  const TranscriptionListItem(
      {super.key,
      required this.onTap,
      required this.file,
      required this.onLongPress,
      required this.onHorizontalDragEnd});

  @override
  Widget build(BuildContext context) {
    String fileName = path.basename(file.uri.toString());

    String parseFileName(String fileName) {
      return fileName.replaceAll("%20", " ");
    }

    return GestureDetector(
      onTap: onTap,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity?.compareTo(0) == 1) {
          // Swiped Right
          onHorizontalDragEnd();
        }
      },
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(parseFileName(fileName)),
                const SizedBox(height: 10),
              ],
            )
          ],
        ),
      ),
    );
  }
}
