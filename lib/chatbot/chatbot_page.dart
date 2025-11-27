// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, deprecated_member_use, unused_local_variable, unused_element

import 'dart:async';
import 'dart:io';
import 'package:digital_krishi/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../chatbot/agri_service.dart';
import '../chatbot/speech_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage>
    with TickerProviderStateMixin {
  final AgriService _service = AgriService();
  final SpeechService _speechService = SpeechService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> messages = [];
  bool loading = false;
  bool listening = false;

  File? pendingImage; // NEW: image preview stored here until user presses send

  // translation options
  final List<String> translationOptions = [
    "English",
    "Hindi",
    "Malayalam",
    "Hinglish",
    "Eng-Malayalam",
  ];

  // --- Typing indicator animation controllers (WhatsApp style)
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _speechService.initSTT();
    _listenToOfficerReplies();

    // Slide controller: slide from left when showing typing bubble
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Dots controller: looping for the three dots
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dotsController.dispose();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// officer replies
  void _listenToOfficerReplies() {
    FirebaseFirestore.instance
        .collection("queries")
        .where(
          "userId",
          isEqualTo: "FARMER_USER_ID",
        ) // <-- replace with real user ID
        .snapshots()
        .listen((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final data = doc.data();

            final String? officerReply = data["response"];
            final String? status = data["status"];

            if (officerReply != null && officerReply.isNotEmpty) {
              // Add officer reply inside chat instantly
              setState(() {
                messages.add({
                  "from": "officer",
                  "msg": officerReply,
                  "image": null,
                  "escalated": false,
                });
              });

              // Save for notifications
              _saveNotification(officerReply);

              // Send local push notification
              NotificationService.showNotification(
                title: "Officer replied",
                body: officerReply,
              );

              _scrollDown();
            }
          }
        });
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

  // Build last 3 messages context (most recent first)
  List<Map<String, dynamic>> _lastThreeContext() {
    final ctx = <Map<String, dynamic>>[];
    for (int i = messages.length - 1; i >= 0 && ctx.length < 3; i--) {
      final m = messages[i];
      if (m["from"] == "user" || m["from"] == "bot") ctx.add(m);
    }
    return ctx;
  }

  // notification

  Future<void> _saveNotification(String message) async {
    await FirebaseFirestore.instance.collection("notifications").add({
      "message": message,
      "timestamp": Timestamp.now(),
      "read": false,
    });
  }

  // NEW SEND: send text + pendingImage together
  Future<void> _send() async {
    final query = _controller.text.trim();
    if (query.isEmpty && pendingImage == null) return;

    // Add user bubble (with pendingImage if present)
    setState(() {
      messages.add({
        "from": "user",
        "msg": query,
        "image": pendingImage,
        "escalated": false,
      });
      loading = true;
    });

    // prepare context
    final last3 = _lastThreeContext();

    // clear input, but keep a local copy of image for sending
    _controller.clear();
    final imageToSend = pendingImage;
    setState(() => pendingImage = null);

    _scrollDown();

    // Show typing indicator (slide in)
    setState(() {
      messages.add({"from": "sys", "type": "typing"});
    });
    _slideController.forward();

    // call API
    String promptForApi = query; // we use context param when calling service
    String ans;
    try {
      ans = await _service.sendMessage(
        promptForApi,
        imageFile: imageToSend,
        lastMessages: last3,
      );
    } catch (e) {
      ans = "⚠️ ERROR: $e";
    }

    // remove typing indicator (slide out) and add bot message with animation
    _slideController.reverse();
    setState(() {
      messages.removeWhere((m) => m["from"] == "sys" && m["type"] == "typing");
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

  // pick image -> store in pendingImage (do NOT send immediately)
  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (x != null) {
      setState(() => pendingImage = File(x.path));
      _scrollDown();
    }
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (x != null) {
      setState(() => pendingImage = File(x.path));
      _scrollDown();
    }
  }

  // mic toggle: start/stop listening and fill input
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

  // thumbs down -> show escalation dialog and save to Firestore
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

                final botReply = messages[msgIndex]["msg"];
                final userMessage =
                    (msgIndex > 0 && messages[msgIndex - 1]["from"] == "user")
                    ? messages[msgIndex - 1]["msg"]
                    : "Unknown";

                // Save escalation to Firestore (matches prior dashboard expectations)
                await FirebaseFirestore.instance.collection("escalations").add({
                  "user_message": userMessage,
                  "bot_reply": botReply,
                  "reason": reasonCtrl.text.trim(),
                  "timestamp": Timestamp.now(),
                  "status": "pending",
                  "userSatisfied": false,
                });

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

  // Translate and REPLACE same bot message (in-place)
  Future<void> _translateInPlace(int index) async {
    final original = messages[index]["msg"] as String? ?? "";
    if (original.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          children: translationOptions.map((lang) {
            return ListTile(
              title: Text("Translate to $lang"),
              onTap: () async {
                Navigator.pop(ctx);

                // show inline loader text
                final old = messages[index]["msg"];
                setState(
                  () => messages[index]["msg"] = "⏳ Translating to $lang...",
                );

                // Prefer translateText helper if present, otherwise fallback to sendMessage prompt
                String translated;
                try {
                  translated = await _service.translateText(original, lang);
                } catch (_) {
                  translated = await _service.sendMessage(
                    "Translate this to $lang. Only translation:\n$original",
                  );
                }

                setState(() {
                  messages[index]["msg"] = translated;
                });

                _scrollDown();
              },
            );
          }).toList(),
        );
      },
    );
  }

  // build bot icons with translate icon calling _translateInPlace
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
        IconButton(
          icon: const Icon(Icons.translate, size: 20),
          onPressed: () => _translateInPlace(index),
        ),
      ],
    );
  }

  // Typing indicator widget (WhatsApp style) — slides in/out and shows 3 bouncing dots
  Widget _typingIndicatorWidget() {
    // uses _slideAnimation and _dotsController
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffE9F8E4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                _bouncingDots(),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // three bouncing dots
  Widget _bouncingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        final t = _dotsController.value; // 0..1
        // three phases for three dots
        double phase(int i) {
          final p = (t + i * 0.2) % 1.0;
          return (p < 0.5) ? (p * 2) : (1 - (p - 0.5) * 2);
        }

        Widget dot(double scale) {
          return Container(
            width: 6 + 6 * scale,
            height: 6 + 6 * scale,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }

        return Row(children: [dot(phase(0)), dot(phase(1)), dot(phase(2))]);
      },
    );
  }

  Widget _bubble(Map<String, dynamic> msg, int index) {
    final isUser = msg["from"] == "user";
    final isOfficer = msg["from"] == "officer"; // NEW
    final hasImage = msg["image"] != null && msg["image"] is File;
    final escalated = msg["escalated"] == true;

    Color bubbleColor = isUser
        ? const Color(0xff058C42)
        : (isOfficer
              ? const Color(0xffd9eaff) // officer BLUE color
              : const Color(0xffE9F8E4)); // normal bot color

    Color textColor = isUser
        ? Colors.white
        : (isOfficer ? Colors.blue[900]! : Colors.black);

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
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
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
                      color: textColor,
                      fontSize: 15,
                      fontWeight: isOfficer
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
          ),

          if (!isUser && !isOfficer)
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
    final sendEnabled =
        _controller.text.trim().isNotEmpty || pendingImage != null;

    return Scaffold(
      backgroundColor: const Color(0xffF3FFF0),
      appBar: AppBar(
        backgroundColor: const Color(0xff058C42),
        title: const Text(
          "Digital Krishi Chatbot",
          style: TextStyle(color: Colors.white),
        ),
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

          // Pending image preview (if any) shown above input
          if (pendingImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      pendingImage!,
                      width: 90,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(child: Text("Image ready to send")),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => pendingImage = null),
                  ),
                ],
              ),
            ),

          // Input area — rounded container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff6fff6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Ask something…",
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      onChanged: (_) =>
                          setState(() {}), // to refresh sendEnabled state
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: sendEnabled ? const Color(0xff058C42) : Colors.grey,
                  ),
                  onPressed: sendEnabled ? _send : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
