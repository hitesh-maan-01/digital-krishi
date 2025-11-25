import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';

import '../chatbot/chatbot_controller.dart';
import '../chatbot/message_model.dart';
import '../chatbot/speech_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final SpeechService _speechService = SpeechService();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String _typedText = '';
  String? _selectedImagePath;
  bool _isListening = false; // State for STT mic animation

  late AnimationController _micIconController;
  late Animation<double> _micIconAnimation;
  bool _showDislikeMessage = false;

  @override
  void initState() {
    super.initState();

    _micIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _micIconAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _micIconController, curve: Curves.easeInOut),
    );

    _controller.addListener(() {
      setState(() {
        _typedText = _controller.text;
      });
    });

    // Ensure initial scroll after the controller loads history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatbotController>(context, listen: false);
      _scrollToBottom();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final controller = Provider.of<ChatbotController>(context, listen: false);
    if (controller.isLoading) return; // Disable while loading/sending

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected. Add your question and send.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  void _showImageSourceDialog() {
    final controller = Provider.of<ChatbotController>(context, listen: false);
    if (controller.isLoading) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Color.fromARGB(255, 5, 150, 105),
              ),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color.fromARGB(255, 5, 150, 105),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _micIconController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Updated sendMessage to delegate logic to ChatbotController
  void sendMessage(String text) async {
    final controller = Provider.of<ChatbotController>(context, listen: false);

    if ((text.trim().isEmpty && _selectedImagePath == null) ||
        controller.isLoading) {
      return;
    }

    HapticFeedback.lightImpact();

    final imagePathToSend = _selectedImagePath;
    final prompt = text.isNotEmpty ? text : 'Analyze this image';

    // Clear UI inputs immediately
    _controller.clear();
    setState(() {
      _typedText = '';
      _selectedImagePath = null;
    });

    // Controller handles adding user message, typing indicator, streaming, and saving history
    await controller.sendMessage(prompt: prompt, imagePath: imagePathToSend);

    // Auto-scroll after receiving the response (triggered by controller's notifyListeners)
    _scrollToBottom();
  }

  void _showHistoryDialog(BuildContext context, ChatbotController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat History'),
        content: SizedBox(
          width: double.maxFinite,
          // Read the messages directly from the controller
          child: controller.messages.isEmpty
              ? const Center(child: Text('No chat history'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    return ListTile(
                      leading: Icon(
                        msg.isUser ? Icons.person : Icons.smart_toy,
                        color: const Color.fromARGB(255, 5, 150, 105),
                      ),
                      title: Text(
                        msg.text.substring(
                          0,
                          msg.text.length > 50 ? 50 : msg.text.length,
                        ),
                      ),
                      // NOTE: We don't have timestamps on the new Message model unless you add it
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearHistory(); // Use controller method
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared')),
              );
            },
            child: const Text(
              'Clear History',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Watch the ChatbotController for all state changes
    final chatbotController = context.watch<ChatbotController>();
    final messages = chatbotController.messages;
    final isLoading = chatbotController.isLoading;

    // Auto-scroll when a new message or message chunk is added
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Digital Krishi Chatbot",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
        elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            // Use controller's loading state to disable button
            onPressed: isLoading
                ? null
                : () => _showHistoryDialog(context, chatbotController),
            tooltip: 'Chat History',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Use controller's loading state for progress indicator
              if (isLoading)
                const LinearProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 240, 253, 244),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 5, 150, 105),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index]; // Message object
                    final isBot = !msg.isUser;
                    return _buildMessageBubble(msg, isBot, index);
                  },
                ),
              ),
              if (_selectedImagePath != null) _buildImagePreview(),
              _buildInputArea(isLoading),
            ],
          ),
          if (_showDislikeMessage) _buildFeedbackSlider(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color.fromARGB(255, 240, 253, 244),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_selectedImagePath!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Image selected', style: TextStyle(fontSize: 14)),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _selectedImagePath = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // Updated _buildMessageBubble to take a Message object
  Widget _buildMessageBubble(Message msg, bool isBot, int index) {
    final bool isUserMessage = msg.isUser;
    final String? imagePath = msg.imagePath;
    // Get controller for feedback actions
    final controller = Provider.of<ChatbotController>(context, listen: false);

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Column(
          crossAxisAlignment: isUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? const Color.fromARGB(255, 5, 150, 105)
                    : const Color.fromARGB(255, 240, 253, 244),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUserMessage
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                  bottomRight: isUserMessage
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imagePath != null && File(imagePath).existsSync())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(imagePath),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  // Use msg.isTyping property
                  msg.isTyping
                      ? _buildTypingIndicator()
                      : MarkdownBody(
                          data: msg.text, // Use msg.text property
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: isUserMessage
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: TextStyle(
                              color: isUserMessage
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (!isUserMessage && !msg.isTyping)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFeedbackIcon(Icons.thumb_up, () {
                      controller.setLikeDislike(index, true); // Use controller
                    }, isSelected: msg.isLiked == true),
                    const SizedBox(width: 8),
                    _buildFeedbackIcon(Icons.thumb_down, () {
                      controller.setLikeDislike(index, false); // Use controller
                      setState(() {
                        _showDislikeMessage = true;
                      });
                      Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          _showDislikeMessage = false;
                        });
                      });
                    }, isSelected: msg.isDisliked == true),
                    const SizedBox(width: 8),
                    // _buildFeedbackIcon(Icons.volume_up, () {
                    //   _speechService.speak(
                    //     msg.text,
                    //     controller
                    //         .getCurrentLanguage(), // Use controller method
                    //   );
                    // }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -5 * (1 - value)),
                  child: const CircleAvatar(
                    radius: 4,
                    backgroundColor: Color.fromARGB(255, 5, 150, 105),
                  ),
                ),
              );
            },
            curve: Interval(
              index * 0.2,
              index * 0.2 + 0.6,
              curve: Curves.easeInOut,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeedbackIcon(
    IconData icon,
    VoidCallback onPressed, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 5, 150, 105)
                : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? const Color.fromARGB(255, 5, 150, 105)
              : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildFeedbackSlider() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.1,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Text(
            'Your query has been escalated!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Updated _buildInputArea to use the isLoading state
  Widget _buildInputArea(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.image,
              color: Color.fromARGB(255, 5, 150, 105),
            ),
            // Use isLoading state to enable/disable
            onPressed: isLoading ? null : _showImageSourceDialog,
            tooltip: 'Add Image',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isLoading, // Use isLoading state
              decoration: InputDecoration(
                hintText: !isLoading ? "Ask something..." : "Loading...",
                filled: true,
                fillColor: const Color.fromARGB(255, 240, 253, 244),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 5, 150, 105),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 5, 150, 105),
                    width: 2.0,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              onSubmitted: !isLoading ? sendMessage : null,
            ),
          ),
          const SizedBox(width: 8),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _typedText.isEmpty && _selectedImagePath == null
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildMicButton(isLoading),
            secondChild: _buildSendButton(isLoading),
          ),
        ],
      ),
    );
  }

  // Updated _buildSendButton to use the isLoading state
  Widget _buildSendButton(bool isLoading) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: !isLoading
            ? const Color.fromARGB(255, 5, 150, 105)
            : Colors.grey,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: !isLoading ? () => sendMessage(_controller.text) : null,
      ),
    );
  }

  // Updated _buildMicButton to use the isLoading state
  Widget _buildMicButton(bool isLoading) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        // Use isLoading instead of _isControllerInitialized
        color: isLoading
            ? Colors.grey
            : _isListening
            ? Colors.redAccent
            : const Color.fromARGB(255, 5, 150, 105),
        shape: BoxShape.circle,
      ),
      child: ScaleTransition(
        scale: _isListening
            ? _micIconAnimation
            : const AlwaysStoppedAnimation(1.0),
        child: IconButton(
          icon: Icon(
            _isListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
          ),
          // Use isLoading instead of _isControllerInitialized
          onPressed: isLoading
              ? null
              : () async {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isListening = !_isListening;
                  });
                  if (_isListening) {
                    _micIconController.repeat(reverse: true);
                    if (await _speechService.initSTT()) {
                      _speechService.listen((text) {
                        if (!_isListening) return;
                        _controller.text = text;
                        setState(() {
                          _typedText = text;
                        });
                      });
                    }
                  } else {
                    _speechService.stopListening();
                    _micIconController.stop();
                  }
                },
        ),
      ),
    );
  }
}
