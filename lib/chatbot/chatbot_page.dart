import 'package:flutter/material.dart';
import '../chatbot/agri_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final AgriService _service = AgriService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Map<String, String>> messages = [];
  bool loading = false;

  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      messages.add({"from": "user", "msg": query});
      loading = true;
    });

    _controller.clear();
    scrollDown();

    final ans = await _service.sendMessage(query);

    setState(() {
      messages.add({"from": "bot", "msg": ans});
      loading = false;
    });

    scrollDown();
  }

  Widget bubble(Map<String, String> msg) {
    final isUser = msg["from"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xff058C42) : const Color(0xffE9F8E4),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          msg["msg"]!,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3FFF0),
      appBar: AppBar(
        backgroundColor: const Color(0xff058C42),
        title: const Text(
          "Digital Krishi Chatbot",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (c, i) => bubble(messages[i]),
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                // Mic Button (not functional yet)
                IconButton(
                  icon: const Icon(Icons.mic),
                  color: const Color(0xff058C42),
                  onPressed: () {},
                ),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something…",
                      border: InputBorder.none,
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),

                loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        color: const Color(0xff058C42),
                        onPressed: sendMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
