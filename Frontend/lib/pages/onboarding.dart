import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:onboarding/onboarding.dart';
import 'package:thelab/code/audio-recorder.dart';
import 'package:thelab/code/bluetooth/BluetoothHandler.dart';
import 'package:thelab/code/widgets/onboarding/onboarding_widget.dart';
import 'package:thelab/pages/record_main.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class OnBoardingVision extends StatefulWidget {
  const OnBoardingVision({super.key});

  @override
  State<OnBoardingVision> createState() => _OnBoardingVisionState();
}

class _OnBoardingVisionState extends State<OnBoardingVision> {
  bool? _isFirstRun;

  Future<bool> _checkFirstRun() async {
    bool ifr = await IsFirstRun.isFirstRun();
    return ifr;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFirstRun(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator if the future is still in progress
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            // Handle error case
            return Center(
              child: Text('Error occurred: ${snapshot.error}'),
            );
          } else {
            // If no error, decide which widget to show based on the result
            var isFirstrun = snapshot.data;
            return isFirstrun!
                ? const LineHeaderIndicator()
                : RecorderApp(bluetoothHandler: BluetoothHandler());
          }
        }
      },
    );
  }
}

class LineHeaderIndicator extends StatefulWidget {
  const LineHeaderIndicator({Key? key}) : super(key: key);

  @override
  State<LineHeaderIndicator> createState() => _LineHeaderIndicatorState();
}

class _LineHeaderIndicatorState extends State<LineHeaderIndicator> {
  late Widget materialButton;
  late int index;
  final activePainter = Paint();
  final inactivePainter = Paint();

  @override
  void initState() {
    super.initState();
    materialButton = _skipButton();
    index = 0;
    activePainter.color = const Color(0xff7f92b1);
    activePainter.strokeWidth = 1;
    activePainter.strokeCap = StrokeCap.round;
    activePainter.style = PaintingStyle.fill;

    inactivePainter.strokeWidth = 1;
    inactivePainter.strokeCap = StrokeCap.round;
    inactivePainter.style = PaintingStyle.stroke;
    inactivePainter.color = const Color(0xff7f92b1);
  }

  Widget _skipButton({void Function(int)? setIndex}) {
    return ElevatedButton(
      onPressed: () {
        if (setIndex != null) {
          index++;
          setIndex(index);
        }
        if (index == 4) return;
        print(index);
      },
      child: const InkWell(
        child: Text(
          'Next',
        ),
      ),
    );
  }

  Widget _pageOne() {
    return  OnboardingWidget(
        title: S.of(context)!.meetTheInventors,
        description: S.of(context)!.welcomeToVision,
           image: 'assets/images/our_team.jpg');
  }

  Widget _pageTwo() {
    return  OnboardingWidget(
        title: S.of(context)!.initiateRecording,
        description: S.of(context)!.beginCommunication,
        image: 'assets/images/home.jpg');
  }

  Widget _pageThree() {
    return  OnboardingWidget(
        title: S.of(context)!.adaptYourStyle,
        description: S.of(context)!.tailorApp,
        image: 'assets/images/settings.jpg');
  }

  Widget _pageFour() {
    return  OnboardingWidget(
        title: S.of(context)!.engageWithVisuals,
        description: S.of(context)!.switchSeamlessly,
        image: 'assets/images/images.png');
  }

  Widget _pageFive() {
    return  OnboardingWidget(
        title: S.of(context)!.congratulations,
        description: S.of(context)!.congratsDes,
        image: 'assets/images/start.png');
  }

  Widget _homeButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RecorderApp(
                    bluetoothHandler: BluetoothHandler(),
                  )),
        );
      },
      child: const InkWell(
        child: Text(
          'Get Started',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Onboarding(
        startIndex: 0,
        onPageChanges: (_, __, currentIndex, sd) {
          index = currentIndex;
        },
        swipeableBody: [
          _pageOne(),
          _pageTwo(),
          _pageThree(),
          _pageFour(),
          _pageFive(),
        ],
        buildHeader:
            (context, dragDistance, pagesLength, currentIndex, setIndex, sd) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context)!
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Indicator<TrianglePainter>(
                    painter: TrianglePainter(
                      currentPageIndex: currentIndex,
                      pagesLength: pagesLength,
                      netDragPercent: dragDistance,
                      activePainter: activePainter,
                      inactivePainter: inactivePainter,
                      slideDirection: sd,
                      translate: false,
                    ),
                  ),
                  index < 4 ? _skipButton(setIndex: setIndex) : _homeButton()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
