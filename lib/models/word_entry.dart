class WordEntry {
  final String word;
  final String? phonetic;
  final List<Phonetic> phonetics;
  final String? origin;
  final List<Meaning> meanings;

  WordEntry({
    required this.word,
    this.phonetic,
    required this.phonetics,
    this.origin,
    required this.meanings,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'],
      phonetic: json['phonetic'],
      phonetics:
          (json['phonetics'] as List).map((p) => Phonetic.fromJson(p)).toList(),
      origin: json['origin'],
      meanings:
          (json['meanings'] as List).map((m) => Meaning.fromJson(m)).toList(),
    );
  }
}

class Phonetic {
  final String? text;
  final String? audio;

  Phonetic({this.text, this.audio});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(
      text: json['text'],
      audio: json['audio'],
    );
  }
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;

  Meaning({required this.partOfSpeech, required this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: (json['definitions'] as List)
          .map((d) => Definition.fromJson(d))
          .toList(),
    );
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String>? synonyms;
  final List<String>? antonyms;

  Definition({
    required this.definition,
    this.example,
    this.synonyms,
    this.antonyms,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'],
      example: json['example'],
      synonyms:
          json['synonyms'] != null ? List<String>.from(json['synonyms']) : null,
      antonyms:
          json['antonyms'] != null ? List<String>.from(json['antonyms']) : null,
    );
  }
}
