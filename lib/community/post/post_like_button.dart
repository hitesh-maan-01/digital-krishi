import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostLikeButton extends StatefulWidget {
  final String postId;
  const PostLikeButton({super.key, required this.postId});

  @override
  State<PostLikeButton> createState() => _PostLikeButtonState();
}

class _PostLikeButtonState extends State<PostLikeButton>
    with SingleTickerProviderStateMixin {
  int likeCount = 0;
  bool isLiked = false;
  bool loading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _loadLikes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLikes() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // If not logged in, just load total likes
      final likesResponse = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', widget.postId);
      setState(() {
        likeCount = (likesResponse as List).length;
        isLiked = false;
        loading = false;
      });
      return;
    }

    final likesResponse = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', widget.postId);

    final userLikeResponse = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', widget.postId)
        .eq('user_id', user.id);

    setState(() {
      likeCount = (likesResponse as List).length;
      isLiked = (userLikeResponse as List).isNotEmpty;
      loading = false;
    });
  }

  Future<void> _toggleLike() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts')),
      );
      return;
    }

    if (isLiked) {
      // remove like
      await supabase
          .from('likes')
          .delete()
          .eq('post_id', widget.postId)
          .eq('user_id', user.id);
    } else {
      // add like
      await supabase.from('likes').insert({
        'post_id': widget.postId,
        'user_id': user.id,
      });
      _animationController.forward(from: 0.0); // Trigger the bounce animation
    }
    // Re-fetch to update UI
    await _loadLikes();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: _toggleLike,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.pink : Colors.grey[700],
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          likeCount.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
