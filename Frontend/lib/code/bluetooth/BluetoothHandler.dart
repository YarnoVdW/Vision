import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothHandler {
  BluetoothConnection? _bluetoothConnection;
  StreamController<bool> _readyStateController =
      StreamController<bool>.broadcast();
  StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();

  BluetoothConnection? get bluetoothConnection => _bluetoothConnection;

  Stream<bool> get readyStateStream => _readyStateController.stream;

  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  Future<void> connectToBluetooth(BluetoothDevice device) async {
    try {
      print("add ${device.address}");
      _bluetoothConnection =
          await BluetoothConnection.toAddress(device.address);
      _readyStateController.add(true);
    } catch (error) {
      if (kDebugMode) {
        print('Error connecting to Bluetooth device: $error');
        _readyStateController.add(false);
      }
    }
  }

  Future<void> getConnectedBluetoothDevice() async {
    List<BluetoothDevice> devices = [];
    print(devices);
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bonded devices');
        print(e);
      }
    }

    if (devices.isNotEmpty) {
      BluetoothDevice selectedDevice = devices
          .firstWhere((device) => device.name?.contains("VisionX") ?? false);
      if (selectedDevice.isConnected) {
        print(selectedDevice.name);
        _connectionStateController.add(true);
        connectToBluetooth(selectedDevice);
      }
    } else {
      _connectionStateController.add(false);
      if (kDebugMode) {
        print(''
            'No bonded Bluetooth devices found');
      }
    }
  }

  void sendTextOverBluetooth(BuildContext context, String text) async {
    text = text.trim();
    if (bluetoothConnection!.isConnected == false) {
      _readyStateController.add(false);
      await getConnectedBluetoothDevice();
    }

    if (text.isEmpty) {
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String fontSize = prefs.getString("font size") ?? "40";
      String fontColour = prefs.getString("font colour") ?? "WHITE";
      fontColour = fontColour.toUpperCase();
      String speed = prefs.getString("speed") ?? "1";

      String formattedText =
          '{ "type": "text", "data": "$text", "font": "Font/arial.ttf", "font_size": $fontSize, "font_colour": "$fontColour", "background_colour": "BLACK", "speed": "$speed"}';

      _bluetoothConnection?.output.add(utf8.encode(formattedText));
      await _bluetoothConnection?.output.allSent;

      if (kDebugMode) {
        print('Text sent over Bluetooth: $formattedText');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending text over Bluetooth');
        _readyStateController.add(false);
        print(e);
      }
    }
  }

  void sendMediaOverBluetooth(String base64) async {
    if (bluetoothConnection!.isConnected == false) {
      _readyStateController.add(false);
      await getConnectedBluetoothDevice();
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLimitedScreenTime = prefs.getBool("limited time") ?? false;
      print("isLimitedScreenTime: $isLimitedScreenTime");
      int screenTime = -1;
      if (isLimitedScreenTime) {
        String screenTimeString = prefs.getString("screen time") ?? "10";
        screenTime = int.tryParse(screenTimeString) ?? 10;
      }

      String start = '{ "start": "1" }';
      String formattedText =
          '{ "type": "media", "data": "$base64",  "screen_time": "$screenTime" } ';
      String stop = '{ "start": "0" }';

      _bluetoothConnection?.output.add(utf8.encode(start));
      await _bluetoothConnection?.output.allSent;

      _bluetoothConnection?.output.add(utf8.encode(formattedText));
      await _bluetoothConnection?.output.allSent;

      _bluetoothConnection?.output.add(utf8.encode(stop));
      await _bluetoothConnection?.output.allSent;

      if (kDebugMode) {
        print('Text sent over Bluetooth: $formattedText');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending text over Bluetooth');
        _readyStateController.add(false);
        print(e);
      }
    }
  }

  void dispose() {
    _bluetoothConnection?.dispose();
    _readyStateController.close();
    _connectionStateController.close();
  }
}
