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

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;

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

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _animationController.dispose();
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
              widget.onSearch(result.recognizedWords);
            });
          },
          onSoundLevelChange: (level) {
            // You can use this to show sound level visualization if needed
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
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchHistory[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed:
                            () => _removeHistoryItem(_searchHistory[index]),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        if (_isListening)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _animation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic,
                          size: 48,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang nghe...',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nói từ khóa tìm kiếm của bạn',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nhấn nút dừng hoặc chạm vào màn hình để kết thúc',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _isListening = false);
                        _speech.stop();
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('Dừng tìm kiếm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
