import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'secret_key.dart';

void main() {
  runApp(const AIGenerativeApp());
}

class AIGenerativeApp extends StatelessWidget {
  const AIGenerativeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appisol AI',
      theme: ThemeData(
        primaryColor: const Color(0xff2d68ec),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xff2d68ec),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AIGenerativeScreen(),
    );
  }
}

class AIGenerativeScreen extends StatefulWidget {
  const AIGenerativeScreen({super.key});

  @override
  AIGenerativeScreenState createState() => AIGenerativeScreenState();
}

class AIGenerativeScreenState extends State<AIGenerativeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _aiResponse = "";
  String _userQuestion = "";
  bool _isProcessing = false;
  bool _isThinking = false;

  Future<void> _generateResponse() async {
    final userPrompt = _controller.text.trim();
    if (userPrompt.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isThinking = true;
      _aiResponse = "";
      _userQuestion = userPrompt;
      _controller.clear();
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

      final content = [Content.text(userPrompt)];
      final response = await model.generateContent(content);
      final words = response.text!.split(" ");
      setState(() {
        _isThinking = false;
      });
      for (final word in words) {
        setState(() {
          _aiResponse += "$word ";
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (error) {
      setState(() {
        _aiResponse = "Error generating response: $error";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_aiResponse.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _aiResponse));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Response copied to clipboard")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SKILL - UP STUDIO',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff2d68ec),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Card(
                  color: Colors.grey[100],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_userQuestion.isNotEmpty)
                            Text(
                              "Q: $_userQuestion",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          if (_userQuestion.isNotEmpty)
                            const SizedBox(height: 8),
                          if (_isThinking)
                            const Text(
                              "Thinking...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          if (!_isProcessing && _aiResponse.isEmpty)
                            const Text(
                              "Your AI response will appear here...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          if (_aiResponse.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _aiResponse,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _copyToClipboard,
                                  icon: const Icon(Icons.copy),
                                  color: const Color(0xff2d68ec),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isProcessing,
                        decoration: const InputDecoration(
                          hintText: "Type your question here...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isProcessing ? null : _generateResponse,
                      icon: const Icon(Icons.send),
                      color:
                          _isProcessing ? Colors.grey : const Color(0xff2d68ec),
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
