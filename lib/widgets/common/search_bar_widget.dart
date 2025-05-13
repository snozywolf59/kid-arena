import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
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
    );
  }
}
