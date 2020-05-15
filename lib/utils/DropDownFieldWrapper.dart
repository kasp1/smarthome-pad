import 'package:flutter/material.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/services.dart';

class DropDownFieldWrapper extends StatelessWidget {
  Map<String, String> options;
  Function(String id, String value) onValueChanged;

  final dynamic value;
  final Widget icon;
  final String hintText;
  final TextStyle hintStyle;
  final String labelText;
  final TextStyle labelStyle;
  final TextStyle textStyle;
  final bool required;
  final bool enabled;
  final List<TextInputFormatter> inputFormatters;
  final FormFieldSetter<dynamic> setter;
  final bool strict;
  final int itemsVisibleInDropdown;
  final TextEditingController controller;

  DropDownFieldWrapper(
      {Key key,
      this.controller,
      this.value,
      this.required: false,
      this.icon,
      this.hintText,
      this.hintStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 18.0),
      this.labelText,
      this.labelStyle: const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.grey, fontSize: 18.0),
      this.inputFormatters,
      this.options,
      this.textStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0),
      this.setter,
      this.onValueChanged,
      this.itemsVisibleInDropdown: 3,
      this.enabled: true,
      this.strict: true})
      : super(key: key);

  List<String> _ids = [];
  List<String> _titles = [];

  @override
  Widget build(BuildContext context) {
    this.options.forEach((String key, String value) {
      _ids.add(key);
      _titles.add(value);
    });

    return DropDownField(
      value: this.value,
      controller: this.controller,
      icon: this.icon,
      required: this.required,
      hintText: this.hintText,
      hintStyle: this.hintStyle,
      labelText: this.labelText,
      labelStyle: this.labelStyle,
      inputFormatters: this.inputFormatters,
      textStyle: this.textStyle,
      itemsVisibleInDropdown: this.itemsVisibleInDropdown,
      enabled: this.enabled,
      items: _titles,
      strict: this.strict,
      setter: this.setter,
      onValueChanged: (dynamic value) {
        String id = (_titles.indexOf(value) >= 0) ? _ids[_titles.indexOf(value)] : null;

        this.onValueChanged(id, value);
      },
    );
  }
}
