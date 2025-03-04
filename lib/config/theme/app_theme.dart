import 'package:flutter/material.dart';

const Color _cumtomColor = Color(0xFF5C11D4);
const List<Color> _colorThemes =[
  _cumtomColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

class AppTheme{
  final int selectedColor;
  AppTheme({this.selectedColor = 0})
      : assert(selectedColor >= 0 && selectedColor <= _colorThemes.length-1,
      'Colors must between 0 and ${_colorThemes.length - 1}');
  ThemeData theme(){
    return ThemeData(
      colorSchemeSeed: _colorThemes[selectedColor]
    );
  }
}