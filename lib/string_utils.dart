import 'package:flutter/material.dart';

class StringUtils {
  static String getFirstSentence(String text) {
    RegExp sentenceSplitter = RegExp(r'(?<=[.?!])\s+(?=[A-Z])');

    List<String> sentences = text.split(sentenceSplitter);

    String firstSentence = sentences.isNotEmpty ? sentences[0] : text;

    return firstSentence;
  }

  static Widget buildTaxonomyRichText(String value) {
    List<String> entries = value.split('\n');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final parts = entry.split(':');
      textSpans.add(
        TextSpan(
          children: [
            TextSpan(
              text: '${parts[0]}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: parts[1]),
            if (i != entries.length - 1) const TextSpan(text: '\n'),
          ],
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 12),
        children: textSpans,
      ),
    );
  }

  static Widget buildWateringRichText(String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const TextSpan(
            text:
                '\neg. "watering": {"max": Dry, "min": Medium} means plant prefers dry to medium environment',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
