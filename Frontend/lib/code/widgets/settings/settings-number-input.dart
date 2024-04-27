import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomNumberInput extends StatefulWidget {
  final int initialValue;
  final String settingsKey;
  final String label;

  const CustomNumberInput({
    Key? key,
    required this.initialValue,
    required this.settingsKey,
    required this.label,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomNumberInputState();
}

class _CustomNumberInputState extends State<CustomNumberInput> {
  late Future<int> _numberValue;

  @override
  void initState() {
    super.initState();
    _numberValue = _loadInitialValue();
  }

  Future<int> _loadInitialValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? loadedValue = prefs.getString(widget.settingsKey);

    if (loadedValue != null) {
      final int parsedValue = int.tryParse(loadedValue) ?? widget.initialValue;
      return parsedValue;
    } else {
      return widget.initialValue;
    }
  }

  void saveSetting(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.settingsKey, value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 50,
      child: FutureBuilder<int>(
        future: _numberValue,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for the value to be loaded
            return const CircularProgressIndicator();
          } else {
            // Handle the loaded value
            final initialValue = snapshot.data ?? widget.initialValue;
            return TextFormField(
              initialValue: initialValue.toString(),
              keyboardType: TextInputType.number,
              onChanged: (newValue) {
                final parsedValue =
                    int.tryParse(newValue) ?? widget.initialValue;
                saveSetting(parsedValue);
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: widget.label,
              ),
            );
          }
        },
      ),
    );
  }
}
