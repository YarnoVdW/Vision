import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCheckbox extends StatefulWidget {
  final bool initialValue;
  final String settingsKey;
  final String label;
  final Function(bool) onChanged;

  const CustomCheckbox({
    super.key,
    required this.initialValue,
    required this.settingsKey,
    required this.label,
    required this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = false;
    _loadCheckboxState();
  }

  Future<void> _loadCheckboxState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isChecked = prefs.getBool(widget.settingsKey) ?? widget.initialValue;
    });
  }

  Future<void> _saveCheckboxState(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.settingsKey, value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: _isChecked,
          onChanged: (value) {
            setState(() {
              _isChecked = value!;
              _saveCheckboxState(value);
            });
          },
        ),
        Text(widget.label),
      ],
    );
  }
}
