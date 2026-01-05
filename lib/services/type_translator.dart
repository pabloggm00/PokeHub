class TypeTranslator {
  static Map<String, String> _translations = {};

  static void setTranslations(Map<String, String> translations) {
    _translations = translations;
  }

  static String translate(String typeCode) {
    return _translations[typeCode.toLowerCase()] ?? typeCode;
  }
}

class StatTranslator {
  static Map<String, String> _translations = {};

  static void setTranslations(Map<String, String> translations) {
    _translations = translations;
  }

  static String translate(String statCode) {
    return _translations[statCode.toLowerCase()] ?? statCode;
  }
}
