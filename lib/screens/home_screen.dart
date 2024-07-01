import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/dictionary_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DictionaryService _dictionaryService = DictionaryService();
  final TextEditingController _searchController = TextEditingController();
  List<WordEntry> _wordEntries = [];
  List<String> _searchHistory = [];
  Set<String> _favorites = {};
  List<String> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
      _favorites = Set<String>.from(prefs.getStringList('favorites') ?? []);
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
    await prefs.setStringList('favorites', _favorites.toList());
  }

  void _updateSearchHistory(String word) {
    setState(() {
      if (!_searchHistory.contains(word)) {
        _searchHistory.insert(0, word);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      }
    });
    _saveData();
  }

  void _toggleFavorite(String word) {
    setState(() {
      if (_favorites.contains(word)) {
        _favorites.remove(word);
      } else {
        _favorites.add(word);
      }
    });
    _saveData();
  }

  void _searchWord(String word) async {
    if (word.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _wordEntries = []; // Clear previous results
    });

    try {
      final entries = await _dictionaryService.getDefinition(word);
      setState(() {
        _wordEntries = entries;
        _updateSearchHistory(word);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  // void _updateSearchHistory(String word) {
  //   if (!_searchHistory.contains(word)) {
  //     _searchHistory.insert(0, word);
  //     if (_searchHistory.length > 10) {
  //       _searchHistory.removeLast();
  //     }
  //   }
  // }

  // void _toggleFavorite(String word) {
  //   setState(() {
  //     if (_favorites.contains(word)) {
  //       _favorites.remove(word);
  //     } else {
  //       _favorites.add(word);
  //     }
  //   });
  // }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    try {
      final suggestions = await _dictionaryService.getSuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: 
      AppBar(
        title: const DefaultTextStyle(
          style: TextStyle(color: Colors.white, fontSize: 24),
          child: Text('makeSense 😎'),
        ),
        shadowColor: Colors.white10,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Text(
                'Your Pocket Dictionary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: primaryColor),
              title: Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                _showFavorites();
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: primaryColor),
              title: Text('History'),
              onTap: () {
                Navigator.pop(context);
                _showHistory();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                _fetchSuggestions(textEditingValue.text);
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _suggestions.where((option) {
                  return option.contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _searchController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search a word ✏️',
                    labelStyle: TextStyle(color: primaryColor),
                    filled: true,
                    fillColor: primaryColor.withOpacity(0.1),
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.close, color: primaryColor),
                            onPressed: () {
                              controller.clear();
                              setState(() {
                                _wordEntries = []; // Clear previous results
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (text) {
                    setState(() {});
                  },
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty) {
                      _searchWord(text);
                    }
                  },
                );
              },
              onSelected: (String selection) {
                if (selection.trim().isNotEmpty) {
                  _searchController.text = selection;
                  _searchWord(selection);
                }
              },
            ),
          ),
          Expanded(
            child: _buildWordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 3, // Number of shimmer items to show
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
                subtitle: Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildWordList() {
    if (_isLoading) {
      return _buildShimmerEffect();
    }

    if (_wordEntries.isEmpty) {
      return Center(child: Text('Hola bruski!'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add horizontal padding
      child: ListView.builder(
        itemCount: _wordEntries.length,
        itemBuilder: (context, index) {
          final entry = _wordEntries[index];
          return Card(
            margin: EdgeInsets.symmetric(
                vertical: 8.0), // Add some vertical spacing between cards
            child: ExpansionTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.word,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (entry.phonetic != null && entry.phonetic!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        entry.phonetic!,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  _favorites.contains(entry.word)
                      ? Icons.star
                      : Icons.star_border,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () => _toggleFavorite(entry.word),
              ),
              children: _buildWordDetails(entry),
            ),
          );
        },
      ),
    );
  }
  List<Widget> _buildWordDetails(WordEntry entry) {
    List<Widget> details = [];

    if (entry.origin != null && entry.origin!.isNotEmpty) {
      details.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Origin: ${entry.origin}',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    details.addAll(entry.meanings.map((meaning) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meaning.partOfSpeech,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            ...meaning.definitions.map((definition) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${definition.definition}',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                    if (definition.example != null &&
                        definition.example!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Example: "${definition.example}"',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 14),
                        ),
                      ),
                    if (definition.synonyms != null &&
                        definition.synonyms!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Synonyms: ${definition.synonyms!.join(", ")}',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    if (definition.antonyms != null &&
                        definition.antonyms!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Antonyms: ${definition.antonyms!.join(", ")}',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    }));

    return details;
  }

  void _showFavorites() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Favorites'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_favorites.elementAt(index)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _searchWord(_favorites.elementAt(index));
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search History'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_searchHistory[index]),
                  onTap: () {
                    Navigator.of(context).pop();
                    _searchWord(_searchHistory[index]);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
