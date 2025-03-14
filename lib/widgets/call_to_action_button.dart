import 'package:flutter/material.dart';

import '../foundation/color.dart';

InkWell button(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    ) {
  final color = MyColor();
  return InkWell(
    onTap: onPressed,
    child: Container(
      decoration: BoxDecoration(
        color: color.mainColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}