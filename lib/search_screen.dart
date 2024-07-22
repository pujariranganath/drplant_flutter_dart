import 'dart:async';
import 'package:dr_plant/plant_response.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dr_plant/api_service.dart';
import 'package:dr_plant/details_result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = "";
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch();
      }
    });
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchText = val.recognizedWords;
            _searchController.text = _searchText;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _performSearch() async {
    String searchText = _searchController.text;
    if (searchText.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _searchResults.clear();
        _hasSearched = true;
      });
      try {
        List<Map<String, String>> results =
            await searchPlantsByName(searchText);
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _getPlantDetails(int index) async {
    String accessToken = _searchResults[index]['access_token']!;
    try {
      Details plantDetails = await getPlantDetailsUsingAPI(accessToken);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsResultScreen(
            plantImage: plantDetails.image!['value'],
            name: _searchResults[index]['entity_name']!,
            description: plantDetails.description?['value'] ?? "",
            url: plantDetails.url,
            plantDetails: plantDetails,
            isSearchCall: true,
            isDiseaseDetailsCall: false,
            accessToken: accessToken,
          ),
        ),
      );
    } catch (e) {
      print('Failed to get plant details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Search Plant...',
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.black,
                    ),
                    onPressed: _startListening,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasSearched && _searchResults.isEmpty
                      ? const Center(child: Text('No results found'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _getPlantDetails(index),
                              child: ListTile(
                                title:
                                    Text(_searchResults[index]['entity_name']!),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
