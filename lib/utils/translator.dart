import 'package:translator/translator.dart';

class Translator {
  static final _translator = GoogleTranslator();

  static Future<String> translate({
    required String text,
    required String from_language,
    required String to_language,
  }) async {
    Translation translation =
        await _translator.translate(text, from: from_language, to: to_language);
    return translation.text;
  }
}
