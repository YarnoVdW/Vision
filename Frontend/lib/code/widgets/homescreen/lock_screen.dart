import 'package:flutter/material.dart';

class LockScreen extends StatefulWidget {
  final Function onPressed;
  final Function onLongPressed;
  final bool isLocked;

  const LockScreen({super.key, required this.onPressed, required this.onLongPressed, required this.isLocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: InkWell(
        child: Icon(
          widget.isLocked ? Icons.lock : Icons.lock_open,
        ),
        onTap: () {
          widget.onPressed();
        },
        onLongPress: () {
          widget.onLongPressed();
        },


      ),
    );
  }


}
