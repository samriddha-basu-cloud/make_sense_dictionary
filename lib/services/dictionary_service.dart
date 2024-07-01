import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_entry.dart';

class DictionaryService {
  static const String baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en/';

  Future<List<WordEntry>> getDefinition(String word) async {
    final response = await http.get(Uri.parse('$baseUrl$word'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => WordEntry.fromJson(json)).toList();
    } else {
      throw Exception('Please Check the Word entered!!');
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    // Mock implementation for suggestions
    final mockSuggestions = [
      'apple',
      'apricot',
      'banana',
      'berry',
      'cherry',
      'date',
      'fig',
      'grape',
      'kiwi',
      'lemon',
      'lime',
      'mango',
      'melon',
      'nectarine',
      'orange',
      'papaya',
      'peach',
      'pear',
      'plum',
      'quince',
      'raspberry',
      'strawberry',
      'tangerine',
      'watermelon',
      // Add more suggestions here
      'pineapple',
      'blueberry',
      'blackberry',
      'pomegranate',
      'coconut',
      'lychee',
      'guava',
      'passionfruit',
      'avocado',
      'dragonfruit',
      'kiwifruit',
      'persimmon',
      'durian',
      'jackfruit',
      'starfruit',
      'mangosteen',
      'cantaloupe',
      'honeydew',
      'cucumber',
      'zucchini',
      'pumpkin',
      'squash',
      'gourd'
    ];

    // Filter suggestions based on the query
    return mockSuggestions
        .where((word) => word.startsWith(query.toLowerCase()))
        .toList();
  }
}
