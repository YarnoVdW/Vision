import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class BuildRecordButton extends StatelessWidget {
  final RecordState recordState;
  final Function() onPressed;

  const BuildRecordButton(
      {super.key, required this.recordState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (recordState == RecordState.record) {
          return _GlowingButton(
            recordState: recordState,
            onPressed: onPressed,
          );
        } else {
          return _MicButton(recordState: recordState, onPressed: onPressed);
        }
      },
    );
  }
}

class _GlowingButton extends StatelessWidget {
  final RecordState recordState;
  final Function() onPressed;

  const _GlowingButton({required this.recordState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: Theme.of(context)!.colorScheme.tertiaryContainer,
      glowShape: BoxShape.circle,
      curve: Curves.fastOutSlowIn,
      child: _MicButton(
        recordState: recordState,
        onPressed: onPressed,
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  final RecordState recordState;
  final Function() onPressed;

  const _MicButton({required this.recordState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 250,
      icon: Image.asset("assets/images/mic.png", color: Theme.of(context)!.colorScheme.tertiary,),
      onPressed: () {
        onPressed();
      },);
  }
}
