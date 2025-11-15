import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'secrets.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _voiceEnabled = true; // 🎚️ controls AI voice reply ON/OFF

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  // 🧠 Load chat memory
  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('chat_history');
    if (savedData != null) {
      setState(() {
        _messages = List<Map<String, String>>.from(json.decode(savedData));
      });
    }
  }

  // 💾 Save memory
  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('chat_history', json.encode(_messages));
  }

  // 🧠 AI response with context
  Future<String> generateAiResponse(String userMessage) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY",
    );

    try {
      // Keep last few messages for context
      final recentMessages = _messages.length > 6
          ? _messages.sublist(_messages.length - 6)
          : _messages;

      final contextMessages = [
        ...recentMessages,
        {"sender": "user", "text": userMessage}
      ];

      final contents = contextMessages.map((msg) {
        return {
          "role": msg["sender"] == "user" ? "user" : "model",
          "parts": [
            {"text": msg["text"]}
          ]
        };
      }).toList();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"contents": contents}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];
        return text ?? "🤖 I couldn’t generate a response right now.";
      } else {
        print("Error body: ${response.body}");
        return "⚠️ Error ${response.statusCode}: ${response.reasonPhrase}";
      }
    } catch (e) {
      return "⚠️ Connection error: $e";
    }
  }

  // 💬 Send message to AI
  Future<void> sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _controller.clear();
    });
    _saveChatHistory();

    // Show AI loading bubble
    setState(() {
      _messages.add({"sender": "ai", "text": "__loading__"});
    });

    // Get AI reply
    final aiReply = await generateAiResponse(text);

    // Replace loading bubble
    setState(() {
      _messages.removeLast();
      _messages.add({"sender": "ai", "text": aiReply});
    });
    _saveChatHistory();

    // 🔊 Speak only if voice is enabled
    if (_voiceEnabled) {
      await _flutterTts.speak(aiReply);
    }
  }

  // 🎙️ Voice input
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Health Assistant 🤖",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.teal[200],
        centerTitle: true,
        actions: [
          // 🎚️ Voice toggle button
          IconButton(
            tooltip: _voiceEnabled ? "Mute AI Voice" : "Unmute AI Voice",
            icon: Icon(
              _voiceEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.yellow[200],
            ),
            onPressed: () {
              setState(() {
                _voiceEnabled = !_voiceEnabled;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear chat",
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('chat_history');
              setState(() => _messages.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.orange[200] : Colors.lightBlue[50],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 18),
                      ),
                    ),
                    child: message["text"] == "__loading__"
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SpinKitThreeBounce(
                                color: Colors.red,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "AI is thinking...",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            message["text"] ?? "",
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask or say something...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.green,
                  ),
                  onPressed: _listen,
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
