import 'dart:js';

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:translatr_backend/utils/utils.dart';

class Translator {
  static final _translator = GoogleTranslator();

  static Map<String, String> languages_to_language_codes = {
    '': 'auto',
    'Amharic': 'am',
    'Arabic': 'ar',
    'Basque': 'eu',
    'Bengali': 'bn',
    'English (UK)': 'en-GB',
    'Portuguese (Brazil)': 'pt-BR',
    'Bulgarian': 'bg',
    'Catalan': 'ca',
    'Cherokee': 'chr',
    'Croatian': 'hr',
    'Czech': 'cs',
    'Danish': 'da',
    'Dutch': 'nl',
    'English (US)': 'en',
    'Estonian': 'et',
    'Filipino': 'fil',
    'Finnish': 'fi',
    'French': 'fr',
    'German': 'de',
    'Greek': 'el',
    'Gujarati': 'gu',
    'Hebrew': 'iw',
    'Hindi': 'hi',
    'Hungarian': 'hu',
    'Icelandic': 'is',
    'Indonesian': 'id',
    'Italian': 'it',
    'Japanese': 'ja',
    'Kannada': 'kn',
    'Korean': 'ko',
    'Latvian': 'lv',
    'Lithuanian': 'lt',
    'Malay': 'ms',
    'Malayalam': 'ml',
    'Marathi': 'mr',
    'Norwegian': 'no',
    'Polish': 'pl',
    'Portuguese (Portugal)': 'pt-PT',
    'Romanian': 'ro',
    'Russian': 'ru',
    'Serbian': 'sr',
    'Chinese (PRC)': 'zh-CN',
    'Slovak': 'sk',
    'Slovenian': 'sl',
    'Spanish': 'es',
    'Swahili': 'sw',
    'Swedish': 'sv',
    'Tamil': 'ta',
    'Telugu': 'te',
    'Thai': 'th',
    'Chinese (Taiwan)': 'zh-TW',
    'Turkish': 'tr',
    'Urdu': 'ur',
    'Ukrainian': 'uk',
    'Vietnamese': 'vi',
    'Welsh': 'cy',
  };

  static String from_language = "";
  static String to_language = "English (US)";

  static Future<String> translate({
    required String text,
  }) async {
    try {
      Translation translation = await _translator.translate(
        text,
        from: languages_to_language_codes[from_language]!,
        to: languages_to_language_codes[to_language]!,
      );
      return translation.text;
    } catch (err) {
      return "error";
    }
  }
}
