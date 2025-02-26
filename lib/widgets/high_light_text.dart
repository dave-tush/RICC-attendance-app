import 'package:flutter/cupertino.dart';

TextSpan highlightText(String source, String query, TextStyle normalStyle,
    TextStyle highLightStyle) {
  if (query.isEmpty || !source.toLowerCase().contains(query.toLowerCase())) {
    return TextSpan(text: source, style: normalStyle);
  }
  final matches = source.toLowerCase().split(query.toLowerCase());
  final List<TextSpan> spans = [];
  int currentIndex = 0;
  for (final part in matches) {
    if (part.isNotEmpty) {
      spans.add(TextSpan(text: part, style: normalStyle));
      currentIndex += part.length;
    }
    if (currentIndex < source.length) {
      spans.add(TextSpan(
          text: source.substring(currentIndex, currentIndex + query.length),
          style: highLightStyle));
      currentIndex += query.length;
    }
  }
  return TextSpan(children: spans);
}
