
class Translator {
  static Future<String> translate(
      {required String text, required String language}) async {
    return "$language translation of '$text'";
  }
}
