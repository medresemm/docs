import 'package:flutter/material.dart';

TextStyle poppins({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  TextDecoration? decoration,
  String? fontFamily,
}) {
  return TextStyle(
    fontFamily: fontFamily ?? 'Poppins',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    decoration: decoration,
  );
}
