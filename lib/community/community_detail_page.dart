// Change the build method to use AnimatedButtonWrapper
// ...
// ignore_for_file: use_build_context_synchronously, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';
import '../community/post/post_like_button.dart';
import '../community/services/user_cache.dart';
import '../community/post/new_post_page.dart';
import '../community/post/post_detail_page.dart';

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

class CommunityDetailPage extends StatefulWidget {
  final Map<String, dynamic> community;
  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  bool _isMember = false;
  late final AnimationController _staggerAnimationController;

  @override
  void initState() {
    super.initState();
    _loadMembership();
    _loadMemberCount();
    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _staggerAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _staggerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadMembership() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _isMember = false);
      return;
    }

    try {
      final res = await supabase
          .from('memberships')
          .select('user_id')
          .eq('community_id', widget.community['id'])
          .eq('user_id', uid);

      setState(() => _isMember = res.isNotEmpty);
    } catch (e) {
      debugPrint('Error loading membership: $e');
      setState(() => _isMember = false);
    }
  }

  Future<void> _loadMemberCount() async {
    try {} catch (e) {
      debugPrint('Error loading member count: $e');
    }
  }

  Future<void> _joinCommunity() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }
    try {
      await supabase.from('memberships').insert({
        'user_id': uid,
        'community_id': widget.community['id'],
      });
      await _loadMembership();
      await _loadMemberCount();
      // DON'T navigate away - just refresh the current page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the community!')),
      );
    } catch (e) {
      debugPrint('Join failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to join: $e')));
    }
  }

  Future<void> _refreshCommunity() async {
    _staggerAnimationController.reset();
    await _loadMembership();
    await _loadMemberCount();
    setState(() {}); // trigger rebuild so StreamBuilder restarts
    _staggerAnimationController.forward();
  }

  Future<void> _leaveCommunity() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await supabase
          .from('memberships')
          .delete()
          .eq('user_id', uid)
          .eq('community_id', widget.community['id']);
      await _loadMembership();
      await _loadMemberCount();
      // DON'T navigate away - just refresh the current page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully left the community!')),
      );
    } catch (e) {
      debugPrint('Leave failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to leave: $e')));
    }
  }

  String? _extractStoragePath(String? publicUrl) {
    if (publicUrl == null || publicUrl.isEmpty) return null;
    try {
      final uri = Uri.parse(publicUrl);
      final segs = uri.pathSegments;
      final idx = segs.indexOf('post_media');
      if (idx >= 0 && idx < segs.length - 1) {
        final pathSegs = segs.sublist(idx + 1);
        return pathSegs.join('/');
      }
      if (segs.length >= 2) {
        return segs.sublist(segs.length - 2).join('/');
      }
    } catch (e) {
      debugPrint('Failed to extract path from url: $e');
    }
    return null;
  }

  Future<void> _deletePost(String postId, String? mediaUrl) async {
    try {
      await supabase.from('posts').delete().eq('id', postId);
      final path = _extractStoragePath(mediaUrl);
      if (path != null) {
        try {
          await supabase.storage.from('post_media').remove([path]);
        } catch (e) {
          debugPrint('Failed to remove media from storage: $e');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
    } catch (e) {
      debugPrint('Delete post failed: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  // Updated query to include comment count from database
  Stream<List<Map<String, dynamic>>> postsStream() {
    return supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('community_id', widget.community['id'])
        .order('created_at', ascending: false)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  Future<void> _navigateToNewPost({Map<String, dynamic>? editPost}) async {
    final refreshed = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => NewPostPage(
          communityId: widget.community['id'],
          editPost: editPost,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
    if (refreshed == true) {
      _refreshCommunity();
    }
  }

  // Function to get real-time comment count
  Future<int> _getCommentCount(String postId) async {
    try {
      final response = await supabase
          .from('comments')
          .select('id')
          .eq('post_id', postId);
      return (response as List).length;
    } catch (e) {
      debugPrint('Error getting comment count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5EE), // Light earth tone
      appBar: AppBar(
        title: Text(
          widget.community['name'] ?? 'Community',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Dark green
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshCommunity,
            tooltip: "Refresh",
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: AnimatedButtonWrapper(
              onTap: _isMember ? _leaveCommunity : _joinCommunity,
              child: TextButton.icon(
                onPressed: _isMember ? _leaveCommunity : _joinCommunity,
                icon: Icon(
                  _isMember
                      ? Icons.person_remove_rounded
                      : Icons.person_add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _isMember ? "Leave" : "Join",
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: _isMember
                      ? const Color(0xFFD32F2F) // Red for leave
                      : const Color(0xFF388E3C), // Green for join
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: postsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No posts yet.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isMember
                            ? 'Be the first to post!'
                            : 'Join to start a conversation.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemBuilder: (context, index) {
                  final post = snapshot.data![index];
                  return AnimatedBuilder(
                    animation: _staggerAnimationController,
                    builder: (context, child) {
                      final animation = CurvedAnimation(
                        parent: _staggerAnimationController,
                        curve: Interval(
                          (index * 0.1),
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                      return Transform.translate(
                        offset: Offset(0, 100 * (1 - animation.value)),
                        child: Opacity(
                          opacity: animation.value,
                          child: InkWell(
                            onTap: () async {
                              final refreshed = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailPage(post: post),
                                ),
                              );
                              if (refreshed == true) {
                                _refreshCommunity();
                              }
                            },
                            child: Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<String>(
                                      future: UserCache.instance.getUserName(
                                        post['user_id'],
                                      ),
                                      builder: (context, nameSnapshot) {
                                        final username =
                                            nameSnapshot.data ?? 'Loading...';
                                        return Text(
                                          'Posted by $username',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      post['content'] ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (post['media_url'] != null &&
                                        post['media_url'].toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            post['media_url'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        PostLikeButton(postId: post['id']),
                                        const Spacer(),
                                        FutureBuilder<int>(
                                          future: _getCommentCount(post['id']),
                                          builder: (context, countSnapshot) {
                                            final commentCount =
                                                countSnapshot.data ?? 0;
                                            return Text(
                                              '$commentCount Comments',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    if (uid == post['user_id']) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () => _navigateToNewPost(
                                              editPost: post,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _deletePost(
                                              post['id'],
                                              post['media_url'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          if (_isMember)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedButtonWrapper(
                        onTap: () => _navigateToNewPost(),
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToNewPost(),
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Write a new post...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
