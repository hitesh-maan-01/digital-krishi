// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

final titleController = TextEditingController(); // ADD THIS

// Add this new widget for a general purpose animated button
class AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AnimatedButtonWrapper({super.key, required this.child, this.onTap});

  @override
  State<AnimatedButtonWrapper> createState() => _AnimatedButtonWrapperState();
}

class _AnimatedButtonWrapperState extends State<AnimatedButtonWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    titleController.dispose(); // ADD THIS
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

class NewPostPage extends StatefulWidget {
  final String? communityId;
  final Map<String, dynamic>? editPost;

  const NewPostPage({super.key, this.communityId, this.editPost});

  @override
  State<NewPostPage> createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final supabase = Supabase.instance.client;
  final contentController = TextEditingController();
  final titleController = TextEditingController(); // ADD THIS
  File? _selectedFile;
  Uint8List? _webImage; // For web image bytes
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      titleController.text = widget.editPost!['title'] ?? ''; // ADD THIS
      contentController.text = widget.editPost!['content'] ?? '';
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    titleController.dispose(); // ADD THIS
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        // On web, read the file as bytes
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedFile = null;
        });
      } else {
        // On mobile, use File
        setState(() {
          _selectedFile = File(picked.path);
          _webImage = null;
        });
      }
    }
  }

  Future<String?> _uploadMedia() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final fileName = "${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final path = "posts/$fileName";

    try {
      if (kIsWeb && _webImage != null) {
        // Upload bytes for web
        await supabase.storage.from('images').uploadBinary(path, _webImage!);
      } else if (_selectedFile != null) {
        // Upload file for mobile
        await supabase.storage.from('images').upload(path, _selectedFile!);
      } else {
        return null;
      }

      final publicUrl = supabase.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }

  Future<void> _savePost() async {
    final isEdit = widget.editPost != null;
    if (contentController.text.trim().isEmpty &&
        _selectedFile == null &&
        _webImage == null) {
      return;
    }
    setState(() => saving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please log in')));
        return;
      }
      String? mediaUrl = widget.editPost?['media_url'];
      if (_selectedFile != null || _webImage != null) {
        final uploaded = await _uploadMedia();
        if (uploaded != null) {
          mediaUrl = uploaded;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload media')),
          );
        }
      }
      if (isEdit) {
        await supabase
            .from('posts')
            .update({
              'title': titleController.text.trim(), // ADD THIS LINE
              'content': contentController.text.trim(),
              'media_url': mediaUrl,
            })
            .eq('id', widget.editPost!['id']);
      } else {
        await supabase.from('posts').insert({
          'title': titleController.text.trim(), // ADD THIS LINE
          'community_id': widget.communityId,
          'user_id': user.id,
          'content': contentController.text.trim(),
          'media_url': mediaUrl,
        });
      }
      if (context.mounted) {
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate a refresh is needed
      }
    } catch (e) {
      debugPrint('Save post failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save post: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(_webImage!, fit: BoxFit.cover),
      );
    } else if (_selectedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_selectedFile!, fit: BoxFit.cover),
      );
    } else if (widget.editPost?['media_url'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(widget.editPost!['media_url'], fit: BoxFit.cover),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editPost != null;
    final hasImage =
        (_selectedFile != null ||
        _webImage != null ||
        widget.editPost?['media_url'] != null);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5EE),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Post" : "New Post"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController, // ADD THIS ENTIRE TEXTFIELD
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 16), // ADD THIS
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: "What's on your mind?",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  labelStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    color: Color(0xFF4CAF50),
                  ),
                ),
                maxLines: null,
                minLines: 5,
              ),
              const SizedBox(height: 16),
              if (hasImage) _buildImagePreview(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButtonWrapper(
                      onTap: _pickImage,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Add Image"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC34A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedButtonWrapper(
                    onTap: saving ? null : _savePost,
                    child: ElevatedButton.icon(
                      onPressed: saving ? null : _savePost,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(isEdit ? "Update" : "Post"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
