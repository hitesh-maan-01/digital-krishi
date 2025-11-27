// lib/pages/chatbot_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../chatbot/agri_service.dart';
import '../chatbot/speech_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final AgriService _service = AgriService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> messages = [];
  bool loading = false;
  bool listening = false;

  // NEW — last language used for translation
  String lastLanguage = "English";

  // NEW — translation options
  final List<String> translationOptions = [
    "English",
    "Hindi",
    "Malayalam",
    "Hinglish",
    "Eng-Malayalam",
  ];

  @override
  void initState() {
    super.initState();
    _speechService.initSTT();
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // NEW — create last 3 messages context
  String _buildContext() {
    final last = messages.reversed
        .where((m) => m["from"] == "user" || m["from"] == "bot")
        .take(3)
        .map((m) => "${m["from"]}: ${m["msg"]}")
        .join("\n");

    return last;
  }

  Future<void> _send({File? image}) async {
    final query = _controller.text.trim();
    if ((query.isEmpty) && image == null) return;

    setState(() {
      messages.add({
        "from": "user",
        "msg": query,
        "image": image,
        "escalated": false,
      });
      loading = true;
    });
    _controller.clear();
    _scrollDown();

    // NEW — append last 3 context
    final finalPrompt = "${_buildContext()}\nUser: $query";

    final ans = await _service.sendMessage(finalPrompt, imageFile: image);

    setState(() {
      messages.add({
        "from": "bot",
        "msg": ans,
        "image": null,
        "escalated": false,
      });
      loading = false;
    });
    _scrollDown();
  }

  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (x != null) await _send(image: File(x.path));
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (x != null) await _send(image: File(x.path));
  }

  void _toggleListening() async {
    if (!listening) {
      final initialized = await _speechService.initSTT();
      if (!initialized) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Speech not available")));
        return;
      }
      setState(() => listening = true);
      _speechService.listen((text) {
        setState(() {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        });
      });
    } else {
      _speechService.stopListening();
      setState(() => listening = false);
    }
  }

  void _readAloud(String text) {
    _speechService.speak(text, langCode: "en-IN");
  }

  void _thumbsUp(int msgIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thanks for your feedback 👍")),
    );
  }

  void _thumbsDown(int msgIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController reasonCtrl = TextEditingController();

        return AlertDialog(
          title: const Text("Escalation / Feedback"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tell us why this answer is not helpful."),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(hintText: "Reason"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);

                // Find user + bot messages
                final botReply = messages[msgIndex]["msg"];
                final userMessage =
                    (msgIndex > 0 && messages[msgIndex - 1]["from"] == "user")
                    ? messages[msgIndex - 1]["msg"]
                    : "Unknown";

                // Save escalation in Firestore EXACTLY as your dashboard expects
                await FirebaseFirestore.instance.collection("escalations").add({
                  "user_message": userMessage,
                  "bot_reply": botReply,
                  "reason": reasonCtrl.text.trim(),
                  "timestamp": Timestamp.now(),
                  "status": "pending", // 🔥 REQUIRED for dashboard filter
                  "userSatisfied": false, // 🔥 MATCH your dashboard
                });

                // Highlight the message
                setState(() => messages[msgIndex]["escalated"] = true);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Escalation submitted.")),
                );
              },
              child: const Text("Escalate"),
            ),
          ],
        );
      },
    );
  }

  // NEW — translate API
  Future<void> _translate(String text, int index) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: translationOptions.map((lang) {
            return ListTile(
              title: Text("Translate to $lang"),
              onTap: () async {
                Navigator.pop(context);
                lastLanguage = lang;

                final translated = await _service.sendMessage(
                  "Translate this to $lang, only translation no explanation:\n$text",
                );

                setState(() {
                  messages.add({
                    "from": "bot",
                    "msg": translated,
                    "image": null,
                    "escalated": false,
                  });
                });
                _scrollDown();
              },
            );
          }).toList(),
        );
      },
    );
  }

  // BOT ICONS + NEW TRANSLATE BUTTON
  Widget _botIcons(int index, String text) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
          onPressed: () => _thumbsUp(index),
        ),
        IconButton(
          icon: const Icon(Icons.thumb_down_alt_outlined, size: 20),
          onPressed: () => _thumbsDown(index),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 20),
          onPressed: () => _readAloud(text),
        ),

        // NEW — translate icon
        IconButton(
          icon: const Icon(Icons.translate, size: 20),
          onPressed: () => _translate(text, index),
        ),
      ],
    );
  }

  Widget _bubble(Map<String, dynamic> msg, int index) {
    final isUser = msg["from"] == "user";
    final hasImage = msg["image"] != null && msg["image"] is File;
    final escalated = msg["escalated"] == true;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xff058C42) : const Color(0xffE9F8E4),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: escalated
                  ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(msg["image"], fit: BoxFit.cover),
                  )
                : Text(
                    msg["msg"] ?? "",
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
          ),

          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _botIcons(index, msg["msg"] ?? ""),
            ),
        ],
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
              itemBuilder: (c, i) => _bubble(messages[i], i),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Color(0xff058C42)),
                  onPressed: _pickGallery,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Color(0xff058C42)),
                  onPressed: _pickCamera,
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
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: listening ? Colors.green : Colors.transparent,
                    ),
                    child: Icon(
                      listening ? Icons.mic : Icons.mic_none,
                      color: const Color(0xff058C42),
                    ),
                  ),
                ),
                loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xff058C42)),
                        onPressed: () => _send(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
