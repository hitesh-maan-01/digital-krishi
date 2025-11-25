// lib/models/message_model.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class Message {
  final String text;
  final bool isUser;
  final String? imagePath;
  final bool isError;
  final bool isTyping;
  final Content? content; // For Gemini Chat History

  bool? isLiked;
  bool? isDisliked;

  Message({
    required this.text,
    required this.isUser,
    this.imagePath,
    this.isError = false,
    this.isTyping = false,
    this.content,
    this.isLiked,
    this.isDisliked,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'imagePath': imagePath,
    'isError': isError,
    'isLiked': isLiked,
    'isDisliked': isDisliked,
    // Convert Content to Map for saving
    'content': content?.toJson(),
  };

  factory Message.fromJson(Map<String, dynamic> json) {
    Content? content;
    if (json['content'] != null) {
      try {
        // FIX 6: Use Content.fromMap instead of Content.fromJson for history parsing
        content = Content.fromMap(json['content'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing Content for history: $e');
      }
    }

    return Message(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      imagePath: json['imagePath'] as String?,
      isError: json['isError'] as bool? ?? false,
      isLiked: json['isLiked'] as bool?,
      isDisliked: json['isDisliked'] as bool?,
      content: content,
      isTyping: false,
    );
  }
}
