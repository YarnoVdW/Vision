# Vision

# About

Introducing our cutting-edge Heads-Up Display (HUD) that revolutionizes how we interact and communicate in diverse linguistic environments. With real-time transcription and translation capabilities, our HUD seamlessly converts spoken conversations into text and offers translations in multiple languages, providing users with instant comprehension and facilitating smooth communication across language barriers. What sets our HUD apart is its customizable display, allowing users to tailor their interface to their preferences, whether it's adjusting font sizes, colors, or layout. Additionally, doubling as a projector, our HUD transforms into a versatile media display, enabling users to project and share various forms of multimedia content directly from compatible applications. With its sleek design and advanced features, our HUD represents the next evolution in augmented communication technology, enhancing connectivity and understanding in today's globalized world.

## The app
The Flutter Vision App project aims to create a mobile application that utilizes speech-to-text functionality for hearing-impaired users. Initially, the project explored various libraries for speech-to-text conversion and encountered challenges with language support and outdated plugins. Ultimately, the project integrated the Google Speech API for its robust speech recognition capabilities and resolved microphone input issues using the Flutter Mic Stream plugin.

### Steps to Build and Run the Flutter App
Run flutter pub get to fetch and update dependencies specified in the pubspec.yaml file. Ensure that a compatible Flutter SDK is installed on your development environment.
Run flutter run to run the app.
Research and Library Exploration
The project began with researching available libraries for speech-to-text conversion in Flutter. A Flutter plugin called 'live-speech-to-text' was initially chosen due to its apparent functionality. However, issues with language support and plugin maintenance quickly surfaced.
Integration of Google Speech API
After encountering limitations with the initial plugin, the project explored alternative solutions. The Google Speech API was identified as a robust solution for speech-to-text conversion. The Speech-to-Text API, with continuous streaming capabilities, was chosen to facilitate real-time conversion of audio to text. The documentation for the Google API can be found here.
Mic Input Problem Resolution
To address mic input issues, the project sought a Flutter plugin that could capture audio input from the device's microphone. The Flutter Mic Stream plugin was selected for its ability to provide a stream of audio data from the microphone input.

More info about flutter mic stream can be found here.

### Vision App
#### Onboarding Experience
When you open the app for the first time, you will be greeted with an interactive onboarding experience. This onboarding will introduce you to the team behind Vision, provide guidance on how to get started, and highlight some key features of the app.

Home Screen
After completing the onboarding, you will be navigated to the home screen. Here, you will find:

* Central Microphone: The central microphone serves as the primary tool for starting recordings. Simply tap on the microphone to begin capturing your moments.
* Settings Sheet: Adjacent to the microphone, you will find a settings sheet. This sheet allows you to customize the user interface (UI) of the display according to your preferences.
* Media Sharing: Additionally, on the home screen, you will find a feature for sending other media. Whether it's images, videos, or documents, you can easily share them using this functionality.
