// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_like_button.dart';
import '../services/user_cache.dart';
import 'dart:math';
import 'dart:async';
import 'dart:io'; // ADD THIS
import 'package:image_picker/image_picker.dart'; // ADD THIS

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final commentController = TextEditingController();

  late Stream<List<Map<String, dynamic>>> _commentStream;
  int _refreshKey = 0;
  // ADD THESE THREE LINES:
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  // ADD THESE THREE LINES FOR REPLY FUNCTIONALITY:
  String? _replyingToCommentId;
  String? _replyingToUsername;
  final FocusNode _commentFocusNode = FocusNode();

  // Seasonal animation controllers
  late AnimationController _seasonController;
  late AnimationController _petalController;

  // Seasonal colors and data
  final List<SeasonTheme> _seasons = [
    SeasonTheme(
      name: 'Spring',
      backgroundColor: const Color(0xFFF0F8EA),
      primaryColor: const Color(0xFF4CAF50),
      accentColor: const Color(0xFF8BC34A),
      cardColor: const Color(0xFFFFFFF3),
      textColor: const Color(0xFF2E7D32),
      petalColor: const Color(0xFFE91E63),
      treeColor: const Color(0xFF388E3C),
    ),
    SeasonTheme(
      name: 'Summer',
      backgroundColor: const Color(0xFFFFF8E1),
      primaryColor: const Color(0xFFFF9800),
      accentColor: const Color(0xFFFFC107),
      cardColor: const Color(0xFFFFFFF8),
      textColor: const Color(0xFFE65100),
      petalColor: const Color(0xFFFFEB3B),
      treeColor: const Color(0xFF689F38),
    ),
    SeasonTheme(
      name: 'Autumn',
      backgroundColor: const Color(0xFFFFF3E0),
      primaryColor: const Color(0xFFFF5722),
      accentColor: const Color(0xFFFF7043),
      cardColor: const Color(0xFFFFFAF0),
      textColor: const Color(0xFFBF360C),
      petalColor: const Color(0xFFFF6F00),
      treeColor: const Color(0xFF8D6E63),
    ),
    SeasonTheme(
      name: 'Winter',
      backgroundColor: const Color(0xFFF3F8FF),
      primaryColor: const Color(0xFF2196F3),
      accentColor: const Color(0xFF03A9F4),
      cardColor: const Color(0xFFFAFCFF),
      textColor: const Color(0xFF0D47A1),
      petalColor: const Color(0xFFE3F2FD),
      treeColor: const Color(0xFF607D8B),
    ),
  ];

  int _currentSeasonIndex = 0;
  List<Petal> _petals = [];
  final Random _random = Random();

  SeasonTheme get _currentSeason => _seasons[_currentSeasonIndex];

  Stream<List<Map<String, dynamic>>> _commentsStream() {
    return supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', widget.post['id'])
        .order('created_at')
        .map((rows) {
          final allComments = List<Map<String, dynamic>>.from(rows);
          // Filter to only show top-level comments (parent_comment_id is null)
          return allComments
              .where((comment) => comment['parent_comment_id'] == null)
              .toList();
        });
  }

  Future<void> _addComment() async {
    if (commentController.text.trim().isEmpty) return;
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedImage != null) {
        final fileName =
            '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'comment_images/$fileName';

        await supabase.storage
            .from('images') // Make sure this bucket exists in Supabase
            .upload(filePath, _selectedImage!);

        imageUrl = supabase.storage.from('images').getPublicUrl(filePath);
      }

      await supabase.from('comments').insert({
        'post_id': widget.post['id'],
        'user_id': user.id,
        'content': commentController.text.trim(),
        'image_url': imageUrl, // Add image URL
        'parent_comment_id': _replyingToCommentId, // ADD THIS LINE
      });

      commentController.clear();
      setState(() {
        _selectedImage = null;
        _isUploading = false;
        _replyingToCommentId = null; // ADD THIS
        _replyingToUsername = null; // ADD THIS
      });
      _refreshComments();
    } catch (e) {
      debugPrint('Add comment failed: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to comment: $e')));
    }
  }

  // ADD THIS ENTIRE FUNCTION:
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  // ADD THIS ENTIRE FUNCTION:
  void _startReply(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  // ADD THIS ENTIRE FUNCTION:

  void _refreshComments() {
    setState(() {
      _refreshKey++;
      _commentStream = _commentsStream();
    });
  }

  void _initializePetals() {
    _petals = List.generate(15, (index) {
      return Petal(
        x: _random.nextDouble(),
        y: _random.nextDouble() * -2,
        size: _random.nextDouble() * 8 + 4,
        rotation: _random.nextDouble() * 2 * pi,
        speed: _random.nextDouble() * 0.02 + 0.01,
        rotationSpeed: _random.nextDouble() * 0.1 - 0.05,
      );
    });
  }

  void _updatePetals() {
    setState(() {
      for (var petal in _petals) {
        petal.y += petal.speed;
        petal.rotation += petal.rotationSpeed;
        petal.x += sin(petal.y * 10) * 0.001;

        if (petal.y > 1.2) {
          petal.y = -0.2;
          petal.x = _random.nextDouble();
        }
      }
    });
  }

  void _changeSeason() {
    setState(() {
      _currentSeasonIndex = (_currentSeasonIndex + 1) % _seasons.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _commentStream = _commentsStream();

    // Initialize seasonal animations
    _seasonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _petalController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..repeat();

    _initializePetals();

    // Auto change seasons every 4 seconds
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        _changeSeason();
      } else {
        timer.cancel();
      }
    });

    // Update petals animation
    _petalController.addListener(_updatePetals);
  }

  @override
  void dispose() {
    commentController.dispose();
    _commentFocusNode.dispose(); // ADD THIS LINE
    _seasonController.dispose();
    _petalController.dispose();
    super.dispose();
  }

  Widget _buildTree() {
    return CustomPaint(
      size: const Size(80, 100),
      painter: TreePainter(_currentSeason.treeColor),
    );
  }

  Widget _buildFallingPetals() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PetalPainter(_petals, _currentSeason.petalColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _currentSeason.backgroundColor,
            _currentSeason.backgroundColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Post Details - ${_currentSeason.name}",
            style: TextStyle(color: _currentSeason.textColor),
          ),
          backgroundColor: _currentSeason.primaryColor.withValues(alpha: 0.1),
          elevation: 0,
          iconTheme: IconThemeData(color: _currentSeason.textColor),
          actions: [
            _buildTree(),
            IconButton(
              icon: Icon(Icons.refresh, color: _currentSeason.textColor),
              onPressed: _refreshComments,
              tooltip: "Refresh",
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            _buildFallingPetals(),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Post header with seasonal styling
                        AnimatedContainer(
                          duration: const Duration(seconds: 3),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentSeason.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _currentSeason.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: _currentSeason.accentColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
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
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _currentSeason.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        'Posted by $username',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: _currentSeason.textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(seconds: 2),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _currentSeason.textColor,
                                    height: 1.5,
                                  ),
                                  child: Text(post['content'] ?? ''),
                                ),
                                if (post['media_url'] != null &&
                                    post['media_url'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: AnimatedContainer(
                                      duration: const Duration(seconds: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _currentSeason.accentColor
                                              .withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.network(
                                          post['media_url'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _currentSeason.accentColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      PostLikeButton(postId: post['id']),
                                      const Spacer(),
                                      Icon(
                                        Icons.comment,
                                        size: 18,
                                        color: _currentSeason.textColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post['comments_count'] ?? 0} Comments',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _currentSeason.textColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Comments section with seasonal styling
                        StreamBuilder<List<Map<String, dynamic>>>(
                          key: ValueKey(_refreshKey),
                          stream: _commentStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: _currentSeason.primaryColor,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                    color: _currentSeason.textColor,
                                  ),
                                ),
                              );
                            }
                            final comments = snapshot.data ?? [];
                            if (comments.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: AnimatedContainer(
                                  duration: const Duration(seconds: 2),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: _currentSeason.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _currentSeason.accentColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'No comments yet. Be the first to comment!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _currentSeason.textColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentWidget(
                                  comment: comment,
                                  seasonTheme: _currentSeason,
                                  onReply: _startReply,
                                  postId: widget.post['id'],
                                  depth: 0,
                                );
                              },
                            );
                            //   return FutureBuilder<String>(
                            //     future: UserCache.instance.getUserName(comment['user_id']),
                            //     builder: (context, nameSnapshot) {
                            //       final username = nameSnapshot.data ?? 'Loading...';
                            //       return AnimatedContainer(
                            //         duration: Duration(milliseconds: 300 + (index * 100)),
                            //         curve: Curves.easeOut,
                            //         margin: const EdgeInsets.symmetric(
                            //           horizontal: 16,
                            //           vertical: 6,
                            //         ),
                            //         decoration: BoxDecoration(
                            //           color: _currentSeason.cardColor,
                            //           borderRadius: BorderRadius.circular(16),
                            //           boxShadow: [
                            //             BoxShadow(
                            //               color: _currentSeason.primaryColor.withValues(alpha: 0.08),
                            //               blurRadius: 8,
                            //               offset: const Offset(0, 4),
                            //             ),
                            //           ],
                            //           border: Border.all(
                            //             color: _currentSeason.accentColor.withValues(alpha: 0.2),
                            //           ),
                            //         ),
                            //         child: Padding(
                            //           padding: const EdgeInsets.all(16),
                            //           child: Column(
                            //             crossAxisAlignment: CrossAxisAlignment.start,
                            //             children: [
                            //               Container(
                            //                 padding: const EdgeInsets.symmetric(
                            //                   horizontal: 8,
                            //                   vertical: 4,
                            //                 ),
                            //                 decoration: BoxDecoration(
                            //                   color: _currentSeason.primaryColor.withValues(alpha: 0.1),
                            //                   borderRadius: BorderRadius.circular(8),
                            //                 ),
                            //                 child: Text(
                            //                   username,
                            //                   style: TextStyle(
                            //                     fontWeight: FontWeight.bold,
                            //                     color: _currentSeason.textColor,
                            //                   ),
                            //                 ),
                            //               ),
                            //               const SizedBox(height: 8),
                            //               Text(
                            //                 comment['content'],
                            //                 style: TextStyle(
                            //                   color: _currentSeason.textColor,
                            //                   height: 1.4,
                            //                 ),
                            //               ),
                            //               // ADD THIS: Display image if exists
                            //               if (comment['image_url'] != null &&
                            //                   comment['image_url'].toString().isNotEmpty)
                            //                 Padding(
                            //                   padding: const EdgeInsets.only(top: 12),
                            //                   child: ClipRRect(
                            //                     borderRadius: BorderRadius.circular(12),
                            //                     child: Image.network(
                            //                       comment['image_url'],
                            //                       width: double.infinity,
                            //                       fit: BoxFit.cover,
                            //                       errorBuilder: (context, error, stackTrace) {
                            //                         return Container(
                            //                           padding: const EdgeInsets.all(8),
                            //                           color: Colors.grey[200],
                            //                           child: const Text('Failed to load image'),
                            //                         );
                            //                       },
                            //                     ),
                            //                   ),
                            //                 ),
                            //             ],
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //   );
                            // },
                            // );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Add comment input with seasonal styling
                SafeArea(
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _currentSeason.cardColor.withValues(alpha: 0.9),
                      border: Border(
                        top: BorderSide(
                          color: _currentSeason.accentColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reply indicator banner - ADD THIS ENTIRE SECTION
                        if (_replyingToCommentId != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: _currentSeason.accentColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _currentSeason.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply,
                                  size: 16,
                                  color: _currentSeason.textColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Replying to $_replyingToUsername',
                                    style: TextStyle(
                                      color: _currentSeason.textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _cancelReply,
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: _currentSeason.textColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        // Image preview (if image selected)
                        if (_selectedImage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _currentSeason.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Input row
                        Row(
                          children: [
                            // Image picker button
                            IconButton(
                              onPressed: _isUploading ? null : _pickImage,
                              icon: Icon(
                                Icons.image,
                                color: _selectedImage != null
                                    ? _currentSeason.primaryColor
                                    : _currentSeason.textColor.withValues(
                                        alpha: 0.6,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Text field
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(seconds: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: _currentSeason.primaryColor
                                        .withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  color: _currentSeason.cardColor,
                                ),
                                child: TextField(
                                  controller: commentController,
                                  focusNode: _commentFocusNode, // ADD THIS LINE
                                  enabled: !_isUploading,
                                  style: TextStyle(
                                    color: _currentSeason.textColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Write a comment...",
                                    hintStyle: TextStyle(
                                      color: _currentSeason.textColor
                                          .withValues(alpha: 0.6),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Send button
                            AnimatedContainer(
                              duration: const Duration(seconds: 2),
                              child: FloatingActionButton(
                                mini: true,
                                onPressed: _isUploading ? null : _addComment,
                                backgroundColor: _currentSeason.primaryColor,
                                elevation: 8,
                                child: _isUploading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Season theme data class
class SeasonTheme {
  final String name;
  final Color backgroundColor;
  final Color primaryColor;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final Color petalColor;
  final Color treeColor;

  SeasonTheme({
    required this.name,
    required this.backgroundColor,
    required this.primaryColor,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    required this.petalColor,
    required this.treeColor,
  });
}

// Petal data class
class Petal {
  double x;
  double y;
  final double size;
  double rotation;
  final double speed;
  final double rotationSpeed;

  Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.rotationSpeed,
  });
}

// Custom painter for falling petals
class PetalPainter extends CustomPainter {
  final List<Petal> petals;
  final Color petalColor;

  PetalPainter(this.petals, this.petalColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = petalColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    for (final petal in petals) {
      canvas.save();
      canvas.translate(petal.x * size.width, petal.y * size.height);
      canvas.rotate(petal.rotation);

      // Draw petal shape
      final path = Path();
      path.addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 0.6,
        ),
      );
      canvas.drawPath(path, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for agricultural tree
class TreePainter extends CustomPainter {
  final Color treeColor;

  TreePainter(this.treeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = treeColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final leavesPaint = Paint()
      ..color = treeColor
      ..style = PaintingStyle.fill;

    // Draw trunk
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.8),
        width: size.width * 0.2,
        height: size.height * 0.4,
      ),
      trunkPaint,
    );

    // Draw leaves (crown)
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.4),
      size.width * 0.3,
      leavesPaint,
    );

    // Draw small fruits/leaves
    final fruitPaint = Paint()
      ..color = treeColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width / 2 + (i - 2) * 8, size.height * 0.4 + sin(i) * 10),
        2,
        fruitPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ADD THIS ENTIRE CLASS BELOW TreePainter:
class CommentWidget extends StatefulWidget {
  final Map<String, dynamic> comment;
  final SeasonTheme seasonTheme;
  final Function(String commentId, String username) onReply;
  final String postId;
  final int depth;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.seasonTheme,
    required this.onReply,
    required this.postId,
    this.depth = 0,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _replies = [];
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    setState(() {});

    try {
      final response = await supabase
          .from('comments')
          .select()
          .eq('post_id', widget.postId)
          .eq('parent_comment_id', widget.comment['id'])
          .order('created_at');

      setState(() {
        _replies = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Error loading replies: $e');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = _replies.isNotEmpty;
    final indentation = widget.depth * 20.0;

    return FutureBuilder<String>(
      future: UserCache.instance.getUserName(widget.comment['user_id']),
      builder: (context, nameSnapshot) {
        final username = nameSnapshot.data ?? 'Loading...';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300 + (widget.depth * 100)),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(
                left: indentation,
                right: 16,
                top: 6,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: widget.seasonTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.seasonTheme.primaryColor.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.seasonTheme.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.seasonTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.seasonTheme.textColor,
                            ),
                          ),
                        ),
                        if (widget.depth > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.seasonTheme.accentColor
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Reply',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.seasonTheme.textColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.comment['content'],
                      style: TextStyle(
                        color: widget.seasonTheme.textColor,
                        height: 1.4,
                      ),
                    ),
                    if (widget.comment['image_url'] != null &&
                        widget.comment['image_url'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.comment['image_url'],
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.grey[200],
                                child: const Text('Failed to load image'),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () =>
                              widget.onReply(widget.comment['id'], username),
                          icon: Icon(
                            Icons.reply,
                            size: 16,
                            color: widget.seasonTheme.textColor,
                          ),
                          label: Text(
                            'Reply',
                            style: TextStyle(
                              color: widget.seasonTheme.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (hasReplies) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showReplies = !_showReplies;
                              });
                            },
                            icon: Icon(
                              _showReplies
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 16,
                              color: widget.seasonTheme.textColor,
                            ),
                            label: Text(
                              '${_replies.length} ${_replies.length == 1 ? 'Reply' : 'Replies'}',
                              style: TextStyle(
                                color: widget.seasonTheme.textColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Nested replies
            if (_showReplies && hasReplies)
              ...(_replies.map(
                (reply) => CommentWidget(
                  comment: reply,
                  seasonTheme: widget.seasonTheme,
                  onReply: widget.onReply,
                  postId: widget.postId,
                  depth: widget.depth + 1,
                ),
              )),
          ],
        );
      },
    );
  }
}
