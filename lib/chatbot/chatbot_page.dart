// lib/pages/chatbot_page.dart
// ignore_for_file: unused_element, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../chatbot/agri_service.dart';
import '../chatbot/speech_service.dart';
import '../notification/notification_service.dart'; // optional: previously provided
import '../notification/notifications_page.dart'; // <-- make sure this file exists (NotificationsPage)

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

  // UI state
  bool loading = false;
  bool listening = false;
  File? pendingImage; // image preview stored until user presses send

  // typing animation controllers (bot)
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _dotsController;

  // officer typing controllers
  bool _officerTyping = false;
  late final AnimationController _officerSlideController;
  late final Animation<Offset> _officerSlideAnimation;

  // track delivered officer notifications to avoid duplicates
  final Set<String> _deliveredOfficerDocIds = {};

  // translation options
  final List<String> translationOptions = [
    "English",
    "Hindi",
    "Malayalam",
    "Hinglish",
    "Eng-Malayalam",
  ];

  // helper to get supabase user id safely
  String? get _supabaseUserId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _speechService.initSTT();

    // bot typing controllers
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // officer typing controllers
    _officerSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _officerSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _officerSlideController,
            curve: Curves.easeOut,
          ),
        );

    // Listen to Firestore chat for generating notifications on officer replies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startOfficerListener();
      _startOfficerTypingListener();
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _slideController.dispose();
    _officerSlideController.dispose();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------- Firestore paths ----------
  CollectionReference<Map<String, dynamic>> _userChatCollection() {
    final uid = _supabaseUserId;
    final id = uid ?? "guest_user";
    return FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("chat");
  }

  CollectionReference<Map<String, dynamic>> _notificationsCollection() {
    final uid = _supabaseUserId ?? "guest_user";
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("notifications");
  }

  // ---------- Listeners ----------

  Future<void> _startOfficerListener() async {
    final uid = _supabaseUserId;
    if (uid == null) return; // user not logged in yet

    final col = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("chat");
    col.snapshots().listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final doc = change.doc;
          final data = doc.data();
          if (data == null) continue;
          final from = (data['from'] ?? '').toString();
          // if officer message and not delivered yet, trigger notification
          if (from == 'officer' && !_deliveredOfficerDocIds.contains(doc.id)) {
            _deliveredOfficerDocIds.add(doc.id);
            final msg = (data['msg'] ?? '').toString();
            // Save a notification document
            try {
              await _notificationsCollection().add({
                "message": msg,
                "timestamp": FieldValue.serverTimestamp(),
                "read": false,
              });
            } catch (_) {}
            // Show local notification (if service available)
            try {
              await NotificationService.showNotification(
                title: "Officer replied",
                body: msg,
              );
            } catch (_) {}
          }
        }
      }
    });
  }

  // Listen to officer typing flag at: users/{uid}/chat_status/status (doc field officerTyping)
  void _startOfficerTypingListener() {
    final uid = _supabaseUserId;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_status')
        .doc('status')
        .snapshots()
        .listen((docSnap) {
          if (!docSnap.exists) return;
          final data = docSnap.data();
          final officerTyping = (data?['officerTyping'] ?? false) as bool;
          if (officerTyping && !_officerTyping) {
            setState(() {
              _officerTyping = true;
              _officerSlideController.forward();
            });
          } else if (!officerTyping && _officerTyping) {
            setState(() {
              _officerTyping = false;
              _officerSlideController.reverse();
            });
          }
        });
  }

  // ---------- Helpers ----------
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

  // get last 3 messages from Firestore (most recent)
  Future<List<Map<String, dynamic>>>
  _getLastThreeMessagesFromFirestore() async {
    final col = _userChatCollection();
    final snap = await col
        .orderBy('timestamp', descending: true)
        .limit(3)
        .get();
    final docs = snap.docs;
    return docs.map((d) {
      final data = d.data();
      return {"from": data['from'] ?? '', "msg": data['msg'] ?? ''};
    }).toList();
  }

  // send user message (text + optional pendingImage)
  Future<void> _send() async {
    final userId = _supabaseUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to send messages.")),
      );
      return;
    }

    final query = _controller.text.trim();
    if (query.isEmpty && pendingImage == null) return;

    // Save user message to Firestore
    final docData = {
      "from": "user",
      "msg": query,
      "image": null,
      "escalated": false,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await _userChatCollection().add(docData);
    } catch (e) {
      // saving failed, continue
    }

    final imageToSend = pendingImage;
    setState(() {
      _controller.clear();
      pendingImage = null;
      loading = true;
    });

    // show bot typing indicator locally
    _slideController.forward();

    // prepare context (last 3 messages)
    final last3 = await _getLastThreeMessagesFromFirestore();

    // call API
    String answer;
    try {
      answer = await _service.sendMessage(
        query,
        imageFile: imageToSend,
        lastMessages: last3,
      );
    } catch (e) {
      answer = "⚠️ ERROR: $e";
    }

    // save bot response
    final botData = {
      "from": "bot",
      "msg": answer,
      "image": null,
      "escalated": false,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await _userChatCollection().add(botData);
    } catch (_) {}

    // hide typing indicator
    _slideController.reverse();
    setState(() {
      loading = false;
    });

    _scrollDown();
  }

  // pick image (store as pending preview, do not send automatically)
  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (x != null) setState(() => pendingImage = File(x.path));
    _scrollDown();
  }

  Future<void> _pickCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (x != null) setState(() => pendingImage = File(x.path));
    _scrollDown();
  }

  // optionally upload image to Firebase Storage and return URL (placeholder)
  Future<String?> _uploadImageToStorage(File image) async {
    return null;
  }

  // read aloud using TTS
  void _readAloud(String text) {
    _speechService.speak(text, langCode: "en-IN");
  }

  // Thumbs up local feedback
  void _thumbsUp(
    int msgIndex,
    DocumentSnapshot<Map<String, dynamic>>? docSnapshot,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thanks for your feedback 👍")),
    );
    if (docSnapshot != null) {
      try {
        docSnapshot.reference.update({"user_feedback": "up"});
      } catch (_) {}
    }
  }

  // Thumbs down -> escalation dialog and save escalation
  void _thumbsDown(
    int msgIndex,
    DocumentSnapshot<Map<String, dynamic>>? docSnapshot,
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final TextEditingController reasonCtrl = TextEditingController();
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: const Text(
            "Escalation / Feedback",
            selectionColor: Color.fromARGB(255, 41, 189, 87),
          ),
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
              child: const Text(
                "Cancel",
                selectionColor: Color.fromARGB(255, 41, 189, 87),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                String botReply = "";
                String userMessage = "";
                if (docSnapshot != null) {
                  botReply = docSnapshot.data()?['msg'] ?? "";
                  final idx = docs.indexWhere((d) => d.id == docSnapshot.id);
                  if (idx > 0) {
                    final prev = docs[idx - 1];
                    if ((prev.data()?['from'] ?? '') == 'user') {
                      userMessage = prev.data()?['msg'] ?? "";
                    }
                  }
                }

                await FirebaseFirestore.instance.collection("escalations").add({
                  "userId": _supabaseUserId ?? "guest_user",
                  "user_message": userMessage,
                  "bot_reply": botReply,
                  "reason": reasonCtrl.text.trim(),
                  "timestamp": FieldValue.serverTimestamp(),
                  "status": "pending",
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Escalation submitted.")),
                  snackBarAnimationStyle: AnimationStyle(
                    curve: ElasticOutCurve(0.4),
                  ),
                );
              },
              child: const Text(
                "Escalate",
                selectionColor: Color.fromARGB(255, 41, 189, 87),
              ),
            ),
          ],
        );
      },
    );
  }

  // Translate and replace same bot message in Firestore
  Future<void> _translateInPlace(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int index,
  ) async {
    final data = doc.data();
    if (data == null) return;
    final original = data['msg']?.toString() ?? "";
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
                try {
                  await doc.reference.update({
                    "msg": "⏳ Translating to $lang...",
                  });
                } catch (_) {}
                String translated;
                try {
                  translated = await _service.translateText(original, lang);
                } catch (_) {
                  translated = await _service.sendMessage(
                    "Translate this to $lang: $original",
                  );
                }
                try {
                  await doc.reference.update({"msg": translated});
                } catch (_) {}
              },
            );
          }).toList(),
        );
      },
    );
  }

  // build icons row for a message
  Widget _iconsRowForMessage(
    DocumentSnapshot<Map<String, dynamic>>? docSnapshot,
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
    int idx,
  ) {
    final data = docSnapshot?.data();
    final from = data?['from'] ?? '';
    if (from != 'bot' && from != 'officer') return const SizedBox.shrink();

    final text = data?['msg'] ?? '';
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
          onPressed: () => _thumbsUp(idx, docSnapshot),
        ),
        IconButton(
          icon: const Icon(Icons.thumb_down_alt_outlined, size: 20),
          onPressed: () => _thumbsDown(idx, docSnapshot, docs),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 20),
          onPressed: () => _readAloud(text),
        ),
        IconButton(
          icon: const Icon(Icons.translate, size: 20),
          onPressed: () {
            if (docSnapshot != null) _translateInPlace(docSnapshot, idx);
          },
        ),
      ],
    );
  }

  // typing indicator widget (WhatsApp style - bot)
  Widget _typingIndicatorWidget() {
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
                AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, child) {
                    final t = _dotsController.value;
                    double phase(int i) {
                      final p = (t + i * 0.2) % 1.0;
                      return (p < 0.5) ? (p * 2) : (1 - (p - 0.5) * 2);
                    }

                    Widget dot(double s) => Container(
                      width: 6 + 6 * s,
                      height: 6 + 6 * s,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                    return Row(
                      children: [dot(phase(0)), dot(phase(1)), dot(phase(2))],
                    );
                  },
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // officer typing widget (slide)
  Widget _officerTypingWidget() {
    return SlideTransition(
      position: _officerSlideAnimation,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xffDDEBFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Officer is typing...",
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(width: 10),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // build a single message bubble from Firestore doc
  Widget _buildBubbleFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int index,
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final data = doc.data() ?? {};
    final from = (data['from'] ?? '').toString();
    final text = (data['msg'] ?? '').toString();
    final escalated = (data['escalated'] ?? false) as bool;
    final isUser = from == 'user';
    final isOfficer = from == 'officer';
    final bubbleColor = isUser
        ? const Color(0xff058C42)
        : (isOfficer ? const Color(0xffd9eaff) : const Color(0xffE9F8E4));
    final textColor = isUser
        ? Colors.white
        : (isOfficer ? Colors.blue[900]! : Colors.black);
    final imageUrl = data['image']?.toString();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(vertical: 6),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
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
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: isOfficer
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
            ),
          ),
          if (!(from == 'user'))
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _iconsRowForMessage(doc, docs, index),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _supabaseUserId;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 255, 240),
      appBar: AppBar(
        backgroundColor: const Color(0xff058C42),
        title: const Text(
          "Digital Krishi Chatbot",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // notifications icon with badge (unread count)
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _notificationsCollection()
                .where("read", isEqualTo: false)
                .snapshots(),
            builder: (context, snap) {
              final count = snap.hasData ? snap.data!.docs.length : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text("Please login to use the chatbot."))
          : Column(
              children: [
                // Chat list (real-time)
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _userChatCollection()
                        .orderBy("timestamp")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      final totalExtra =
                          (loading ? 1 : 0) + (_officerTyping ? 1 : 0);
                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(12),
                        itemCount: docs.length + totalExtra,
                        itemBuilder: (context, idx) {
                          // show documents first
                          if (idx < docs.length) {
                            final doc = docs[idx];
                            return _buildBubbleFromDoc(doc, idx, docs);
                          }

                          // after docs, show officer typing (if active) then bot typing
                          final extraIndex = idx - docs.length;
                          if (_officerTyping && extraIndex == 0) {
                            return _officerTypingWidget();
                          }
                          // If both present and officer was first, bot typing will be next (extraIndex 1)
                          if (loading &&
                              ((_officerTyping && extraIndex == 1) ||
                                  (!_officerTyping && extraIndex == 0))) {
                            return _typingIndicatorWidget();
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    },
                  ),
                ),

                // Pending image preview
                if (pendingImage != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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

                // Input bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo, color: Color(0xff058C42)),
                        onPressed: _pickGallery,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Color(0xff058C42),
                        ),
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
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (!listening) {
                            final ok = await _speechService.initSTT();
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Speech not available"),
                                ),
                              );
                              return;
                            }
                            setState(() => listening = true);
                            _speechService.listen((text) {
                              setState(() {
                                _controller.text = text;
                                _controller
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: _controller.text.length),
                                );
                              });
                            });
                          } else {
                            _speechService.stopListening();
                            setState(() => listening = false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: listening
                                ? Colors.green
                                : Colors.transparent,
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
                          color:
                              (_controller.text.trim().isNotEmpty ||
                                  pendingImage != null)
                              ? const Color(0xff058C42)
                              : Colors.grey,
                        ),
                        onPressed:
                            (_controller.text.trim().isNotEmpty ||
                                pendingImage != null)
                            ? _send
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
