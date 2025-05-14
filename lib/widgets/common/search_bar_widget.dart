import 'package:flutter/material.dart';
import 'package:kid_arena/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController controller;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.controller,
    required this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final FocusNode _focusNode = FocusNode();

  List<String> _searchHistory = [];
  final String _searchHistoryKey = 'search_history';

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.text != widget.controller.text) {
      _saveSearchTerm(widget.controller.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onSearch(widget.controller.text);
    }
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              widget.controller.text = result.recognizedWords;
              // Trigger search immediately after voice input
              widget.onSearch(result.recognizedWords);
            });
          },
          localeId: 'vi_VN',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = getIt<SharedPreferences>();
    setState(() {
      _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
    });
  }

  Future<void> _saveSearchTerm(String term) async {
    final prefs = getIt<SharedPreferences>();

    // Xoá từ khoá trùng nếu đã có và thêm mới vào đầu danh sách
    _searchHistory.remove(term);
    _searchHistory.insert(0, term);

    // Giới hạn số lượng lịch sử (tuỳ chọn)
    if (_searchHistory.length > 5) {
      _searchHistory = _searchHistory.sublist(0, 5);
    }

    await prefs.setStringList(_searchHistoryKey, _searchHistory);
  }

  void _removeHistoryItem(String term) async {
    final prefs = getIt<SharedPreferences>();
    _searchHistory.remove(term);
    await prefs.setStringList(_searchHistoryKey, _searchHistory);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    widget.onSearch(value);
                    _focusNode.unfocus();
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color:
                      _isListening
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _startListening,
              ),
            ],
          ),
          if (_searchHistory.isNotEmpty)
            ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchHistory[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeHistoryItem(_searchHistory[index]),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
