import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDropDown<T> extends StatefulWidget {
  CustomDropDown({
    super.key,
    required this.settingKey,
    required this.items,
    this.labels,
    required this.initialValue,
    required this.title,
    this.event,
  });

  final String settingKey;
  final List<T> items;
  final List<String>? labels;
  final T initialValue;
  final String title;
  VoidCallback? event;

  @override
  State<CustomDropDown<T>> createState() => _CustomDropDownState<T>();
}

class _CustomDropDownState<T> extends State<CustomDropDown<T>> {
  final TextEditingController controller = TextEditingController();
  T? selectedItem;

  void saveSetting(T value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(widget.settingKey, value.toString());
  }

  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? initialValue = prefs.getString(widget.settingKey);

    if (initialValue != null) {
      final T parsedValue = widget.items.firstWhere(
        (element) => element.toString() == initialValue,
        orElse: () => widget.initialValue,
      );
      setState(() {
        selectedItem = parsedValue;
      });
    } else {
      setState(() {
        selectedItem = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: widget.title,
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
          border:  OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)),
          focusColor: Theme.of(context).colorScheme.tertiary,
        ),
        value: selectedItem,
        onChanged: (T? value) {
          setState(() {
            selectedItem = value;
          });
          saveSetting(value!);
          if (widget.event != null) {
            widget.event?.call();
          }
        },
        items: List.generate(widget.items.length, (index) {
          return DropdownMenuItem<T>(
            value: widget.items[index],
            child: Text(
              widget.labels != null ? widget.labels![index] : widget.items[index].toString(),
              style: const TextStyle(fontSize: 16.0),
            ),
          );
        }),
      ),
    );
  }
}
