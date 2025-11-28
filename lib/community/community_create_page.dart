// Enhanced UI/UX with seasonal transitions and falling petals
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;

// Seasonal Theme Data
class SeasonalTheme {
  final String name;
  final List<Color> backgroundGradient;
  final List<Color> cardGradient;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color treeLeafColor;
  final Color treeTrunkColor;
  final List<Color> petalColors;
  final IconData seasonIcon;

  const SeasonalTheme({
    required this.name,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.treeLeafColor,
    required this.treeTrunkColor,
    required this.petalColors,
    required this.seasonIcon,
  });
}

// Seasonal themes
final List<SeasonalTheme> seasons = [
  // Spring
  const SeasonalTheme(
    name: "Spring",
    backgroundGradient: [
      Color(0xFFE8F5E8),
      Color(0xFFF0F8E8),
      Color(0xFFE1F5FE),
    ],
    cardGradient: [Color(0xFFE8F5E8), Color(0xFFF1F8E9)],
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFF66BB6A),
    accentColor: Color(0xFF81C784),
    treeLeafColor: Color(0xFF4CAF50),
    treeTrunkColor: Color(0xFF8D6E63),
    petalColors: [
      Color(0xFFFFB3BA),
      Color(0xFFFFDFBA),
      Color(0xFFFFFFBA),
      Color(0xFFBAFFC9),
    ],
    seasonIcon: Icons.local_florist,
  ),
  // Summer
  const SeasonalTheme(
    name: "Summer",
    backgroundGradient: [
      Color(0xFFFFF3E0),
      Color(0xFFFFF8E1),
      Color(0xFFE8F5E8),
    ],
    cardGradient: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
    primaryColor: Color(0xFFFF9800),
    secondaryColor: Color(0xFFFFB74D),
    accentColor: Color(0xFFFFCC02),
    treeLeafColor: Color(0xFF2E7D32),
    treeTrunkColor: Color(0xFF6D4C41),
    petalColors: [
      Color(0xFFFFE082),
      Color(0xFFFFCC02),
      Color(0xFFFF8F00),
      Color(0xFFFFB74D),
    ],
    seasonIcon: Icons.wb_sunny,
  ),
  // Autumn
  const SeasonalTheme(
    name: "Autumn",
    backgroundGradient: [
      Color(0xFFFFE0B2),
      Color(0xFFFFECB3),
      Color(0xFFFFCC80),
    ],
    cardGradient: [Color(0xFFFFE0B2), Color(0xFFFFECB3)],
    primaryColor: Color(0xFFFF5722),
    secondaryColor: Color(0xFFFF7043),
    accentColor: Color(0xFFFFAB40),
    treeLeafColor: Color(0xFFFF5722),
    treeTrunkColor: Color(0xFF5D4037),
    petalColors: [
      Color(0xFFFF5722),
      Color(0xFFFF7043),
      Color(0xFFFFAB40),
      Color(0xFFFF8A65),
    ],
    seasonIcon: Icons.eco,
  ),
  // Winter
  const SeasonalTheme(
    name: "Winter",
    backgroundGradient: [
      Color(0xFFE3F2FD),
      Color(0xFFE8F4F8),
      Color(0xFFF0F4F8),
    ],
    cardGradient: [Color(0xFFE3F2FD), Color(0xFFE8F4F8)],
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF42A5F5),
    accentColor: Color(0xFF64B5F6),
    treeLeafColor: Color(0xFF90CAF9),
    treeTrunkColor: Color(0xFF616161),
    petalColors: [
      Color(0xFFE3F2FD),
      Color(0xFFBBDEFB),
      Color(0xFF90CAF9),
      Color(0xFF64B5F6),
    ],
    seasonIcon: Icons.ac_unit,
  ),
];

// Seasonal Controller
class SeasonalController extends ChangeNotifier {
  late AnimationController _seasonController;
  late Animation<double> _seasonAnimation;
  int _currentSeasonIndex = 0;
  SeasonalTheme _currentTheme = seasons[0];
  SeasonalTheme _nextTheme = seasons[1];

  SeasonalController(TickerProvider vsync) {
    _seasonController = AnimationController(
      duration: const Duration(seconds: 4), // Smooth 4-second transition
      vsync: vsync,
    );

    _seasonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _seasonController, curve: Curves.easeInOut),
    );

    _seasonController.addListener(() => notifyListeners());
    _seasonController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentSeasonIndex = (_currentSeasonIndex + 1) % seasons.length;
        _currentTheme = seasons[_currentSeasonIndex];
        _nextTheme = seasons[(_currentSeasonIndex + 1) % seasons.length];
        _seasonController.reset();
        Future.delayed(const Duration(seconds: 1), () {
          if (!_seasonController.isAnimating) {
            _seasonController.forward();
          }
        });
      }
    });

    // Start the seasonal cycle
    Future.delayed(const Duration(seconds: 2), () {
      _seasonController.forward();
    });
  }

  SeasonalTheme get currentTheme => _currentTheme;
  SeasonalTheme get nextTheme => _nextTheme;
  double get progress => _seasonAnimation.value;

  // Interpolate colors between current and next season
  Color lerpColor(Color current, Color next) {
    return Color.lerp(current, next, progress) ?? current;
  }

  List<Color> lerpGradient(List<Color> current, List<Color> next) {
    return List.generate(current.length, (index) {
      return Color.lerp(current[index], next[index % next.length], progress) ??
          current[index];
    });
  }

  @override
  void dispose() {
    _seasonController.dispose();
    super.dispose();
  }
}

// Enhanced Animated Tree with Seasonal Colors
class AnimatedTree extends StatefulWidget {
  final double size;
  final SeasonalController seasonalController;

  const AnimatedTree({
    super.key,
    this.size = 100,
    required this.seasonalController,
  });

  @override
  State<AnimatedTree> createState() => _AnimatedTreeState();
}

class _AnimatedTreeState extends State<AnimatedTree>
    with TickerProviderStateMixin {
  late AnimationController _swayController;
  late AnimationController _growController;
  late AnimationController _leafController;
  late Animation<double> _swayAnimation;
  late Animation<double> _growAnimation;
  late Animation<double> _leafAnimation;

  @override
  void initState() {
    super.initState();

    _swayController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _growController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _leafController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _swayAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _swayController, curve: Curves.easeInOut),
    );

    _growAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growController, curve: Curves.elasticOut),
    );

    _leafAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeInOut),
    );

    _growController.forward();
  }

  @override
  void dispose() {
    _swayController.dispose();
    _growController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _swayAnimation,
        _growAnimation,
        _leafAnimation,
        widget.seasonalController,
      ]),
      builder: (context, child) {
        final leafColor = widget.seasonalController.lerpColor(
          widget.seasonalController.currentTheme.treeLeafColor,
          widget.seasonalController.nextTheme.treeLeafColor,
        );
        final trunkColor = widget.seasonalController.lerpColor(
          widget.seasonalController.currentTheme.treeTrunkColor,
          widget.seasonalController.nextTheme.treeTrunkColor,
        );

        return Transform.scale(
          scale: _growAnimation.value,
          child: Transform.rotate(
            angle: _swayAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: TreePainter(
                trunkColor: trunkColor,
                leafColor: leafColor,
                leafScale: _leafAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Enhanced TreePainter with more agricultural details
class TreePainter extends CustomPainter {
  final Color trunkColor;
  final Color leafColor;
  final double leafScale;

  const TreePainter({
    required this.trunkColor,
    required this.leafColor,
    required this.leafScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = trunkColor
      ..style = PaintingStyle.fill;
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    final branchPaint = Paint()
      ..color = trunkColor.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw main trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.7),
          width: size.width * 0.15,
          height: size.height * 0.6,
        ),
        const Radius.circular(8),
      ),
      trunkPaint,
    );

    // Draw branches
    final branchPath = Path();
    final center = Offset(size.width / 2, size.height * 0.5);

    // Left branch
    branchPath.moveTo(center.dx, center.dy);
    branchPath.quadraticBezierTo(
      center.dx - size.width * 0.2,
      center.dy - size.height * 0.1,
      center.dx - size.width * 0.25,
      center.dy - size.height * 0.15,
    );

    // Right branch
    branchPath.moveTo(center.dx, center.dy);
    branchPath.quadraticBezierTo(
      center.dx + size.width * 0.2,
      center.dy - size.height * 0.1,
      center.dx + size.width * 0.25,
      center.dy - size.height * 0.15,
    );

    canvas.drawPath(branchPath, branchPaint);

    // Draw leaves with animation
    final leafCenter = Offset(size.width / 2, size.height * 0.3);
    canvas.save();
    canvas.translate(leafCenter.dx, leafCenter.dy);
    canvas.scale(leafScale);
    canvas.translate(-leafCenter.dx, -leafCenter.dy);

    // Multiple leaf clusters for agricultural look
    for (int i = 0; i < 7; i++) {
      final angle = (i * math.pi * 2 / 7);
      final radius = size.width * 0.15 + (i % 2) * size.width * 0.05;
      final offset = Offset(
        leafCenter.dx + math.cos(angle) * radius,
        leafCenter.dy + math.sin(angle) * size.height * 0.08,
      );
      canvas.drawCircle(offset, size.width * 0.12 + (i % 3) * 0.02, leafPaint);
    }

    // Central leaf cluster
    canvas.drawCircle(leafCenter, size.width * 0.2, leafPaint);

    // Add small fruits/flowers for agricultural theme
    final fruitPaint = Paint()
      ..color = leafColor.withRed((leafColor.red * 1.5).toInt().clamp(0, 255));
    for (int i = 0; i < 5; i++) {
      final angle = (i * math.pi * 2 / 5) + math.pi / 5;
      final offset = Offset(
        leafCenter.dx + math.cos(angle) * size.width * 0.18,
        leafCenter.dy + math.sin(angle) * size.height * 0.06,
      );
      canvas.drawCircle(offset, size.width * 0.03, fruitPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Falling Petals Widget
class FallingPetals extends StatefulWidget {
  final SeasonalController seasonalController;

  const FallingPetals({super.key, required this.seasonalController});

  @override
  State<FallingPetals> createState() => _FallingPetalsState();
}

class _FallingPetalsState extends State<FallingPetals>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _positions;
  late List<Animation<double>> _rotations;
  late List<Animation<double>> _opacity;
  late List<int> _petalTypes;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _positions = [];
    _rotations = [];
    _opacity = [];
    _petalTypes = [];

    // Create 15 petals
    for (int i = 0; i < 15; i++) {
      final duration = Duration(seconds: 6 + (i % 4) * 2);
      final controller = AnimationController(duration: duration, vsync: this)
        ..repeat();

      final startX = -0.1 + (i * 0.08) + (math.Random().nextDouble() * 0.2);
      final endX = startX + (math.Random().nextDouble() * 0.4 - 0.2);

      final position = Tween<Offset>(
        begin: Offset(startX, -0.1),
        end: Offset(endX, 1.1),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      final rotation = Tween<double>(
        begin: 0,
        end: math.pi * 4 + (math.Random().nextDouble() * math.pi * 2),
      ).animate(controller);

      final opacity = Tween<double>(begin: 0.0, end: 0.8).animate(
        CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.1)),
      );

      _controllers.add(controller);
      _positions.add(position);
      _rotations.add(rotation);
      _opacity.add(opacity);
      _petalTypes.add(i % 4); // 4 different petal types per season
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.seasonalController,
      builder: (context, child) {
        return Stack(
          children: _positions.asMap().entries.map((entry) {
            final index = entry.key;
            final position = entry.value;
            final petalTypeIndex = _petalTypes[index];

            final currentColors =
                widget.seasonalController.currentTheme.petalColors;
            final nextColors = widget.seasonalController.nextTheme.petalColors;

            final petalColor = widget.seasonalController.lerpColor(
              currentColors[petalTypeIndex],
              nextColors[petalTypeIndex],
            );

            return AnimatedBuilder(
              animation: Listenable.merge([
                position,
                _rotations[index],
                _opacity[index],
              ]),
              builder: (context, child) {
                return SlideTransition(
                  position: position,
                  child: Transform.rotate(
                    angle: _rotations[index].value,
                    child: Opacity(
                      opacity: _opacity[index].value,
                      child: Icon(
                        Icons.local_florist,
                        size: 16 + (index % 3) * 4,
                        color: petalColor,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// Enhanced Floating Elements with Seasonal Colors
class FloatingElements extends StatefulWidget {
  final SeasonalController seasonalController;

  const FloatingElements({super.key, required this.seasonalController});

  @override
  State<FloatingElements> createState() => _FloatingElementsState();
}

class _FloatingElementsState extends State<FloatingElements>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];

    for (int i = 0; i < 8; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 10 + i * 2),
        vsync: this,
      )..repeat();

      final animation = Tween<Offset>(
        begin: Offset(-0.2, 0.1 + i * 0.12),
        end: Offset(1.2, 0.2 + i * 0.1),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.linear));

      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.seasonalController,
      builder: (context, child) {
        final iconColor = widget.seasonalController.lerpColor(
          widget.seasonalController.currentTheme.accentColor,
          widget.seasonalController.nextTheme.accentColor,
        );

        return Stack(
          children: _animations.asMap().entries.map((entry) {
            final index = entry.key;
            final animation = entry.value;
            const icons = [
              Icons.eco,
              Icons.grass,
              Icons.local_florist,
              Icons.agriculture,
              Icons.park,
              Icons.nature,
              Icons.spa,
              Icons.energy_savings_leaf,
            ];

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return SlideTransition(
                  position: animation,
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(
                      icons[index],
                      size: 20 + (index % 4) * 6,
                      color: iconColor,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// Enhanced Animated Button Wrapper with Seasonal Colors
class AnimatedButtonWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final SeasonalController seasonalController;

  const AnimatedButtonWrapper({
    super.key,
    required this.child,
    required this.seasonalController,
    this.onTap,
  });

  @override
  State<AnimatedButtonWrapper> createState() => _AnimatedButtonWrapperState();
}

class _AnimatedButtonWrapperState extends State<AnimatedButtonWrapper>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _glowAnimation,
          widget.seasonalController,
        ]),
        builder: (context, child) {
          final glowColor = widget.seasonalController.lerpColor(
            widget.seasonalController.currentTheme.primaryColor,
            widget.seasonalController.nextTheme.primaryColor,
          );

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 3 * _glowAnimation.value,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

class CommunityCreatePage extends StatefulWidget {
  const CommunityCreatePage({super.key});

  @override
  State<CommunityCreatePage> createState() => _CommunityCreatePageState();
}

class _CommunityCreatePageState extends State<CommunityCreatePage>
    with TickerProviderStateMixin {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool loading = false;
  File? selectedImage;
  Uint8List? webImageBytes;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _pageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late SeasonalController _seasonalController;

  @override
  void initState() {
    super.initState();
    _seasonalController = SeasonalController(this);

    _pageController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageController, curve: Curves.easeOut));

    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _seasonalController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            webImageBytes = bytes;
          });
        } else {
          setState(() {
            selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'community_images/$fileName';

      if (kIsWeb && webImageBytes != null) {
        await supabase.storage
            .from('images')
            .uploadBinary(
              filePath,
              webImageBytes!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else if (selectedImage != null) {
        await supabase.storage
            .from('images')
            .upload(
              filePath,
              selectedImage!,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        return null;
      }

      final publicUrl = supabase.storage.from('images').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Image upload error: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> createCommunity() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a community name')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      String? imageUrl;

      if ((selectedImage != null) || (webImageBytes != null)) {
        imageUrl = await _uploadImage();
      }

      final response = await supabase
          .from('communities')
          .insert({
            'name': nameController.text.trim(),
            'description': descriptionController.text.trim(),
            'created_by': user.id,
            'image_url': imageUrl,
          })
          .select()
          .single();

      final communityId = response['id'];

      await supabase.from('memberships').insert({
        'user_id': user.id,
        'community_id': communityId,
      });

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create community: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _buildImagePicker() {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        final cardGradient = _seasonalController.lerpGradient(
          _seasonalController.currentTheme.cardGradient,
          _seasonalController.nextTheme.cardGradient,
        );
        final primaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.primaryColor,
          _seasonalController.nextTheme.primaryColor,
        );
        final secondaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.secondaryColor,
          _seasonalController.nextTheme.secondaryColor,
        );

        return Column(
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: cardGradient,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: (selectedImage != null || webImageBytes != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: kIsWeb && webImageBytes != null
                              ? Image.memory(webImageBytes!, fit: BoxFit.cover)
                              : selectedImage != null
                              ? Image.file(selectedImage!, fit: BoxFit.cover)
                              : null,
                        )
                      : Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: 48,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Add Community Photo',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        color: primaryColor.withBlue(
                                          (primaryColor.blue * 0.8).toInt(),
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '(Optional)',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: secondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Seasonal decorative elements
                            Positioned(
                              top: 16,
                              right: 16,
                              child: AnimatedTree(
                                size: 40,
                                seasonalController: _seasonalController,
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Icon(
                                _seasonalController.currentTheme.seasonIcon,
                                color: primaryColor.withOpacity(0.4),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AnimatedButtonWrapper(
                    seasonalController: _seasonalController,
                    onTap: loading ? null : _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [secondaryColor, primaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : _pickImage,
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                        ),
                        label: Text(
                          (selectedImage != null || webImageBytes != null)
                              ? 'Change Image'
                              : 'Select Image',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedImage != null || webImageBytes != null) ...[
                  const SizedBox(width: 12),
                  AnimatedButtonWrapper(
                    seasonalController: _seasonalController,
                    onTap: loading
                        ? null
                        : () {
                            setState(() {
                              selectedImage = null;
                              webImageBytes = null;
                            });
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: loading
                            ? null
                            : () {
                                setState(() {
                                  selectedImage = null;
                                  webImageBytes = null;
                                });
                              },
                        icon: Icon(Icons.clear, color: Colors.grey[700]),
                        label: Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        final primaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.primaryColor,
          _seasonalController.nextTheme.primaryColor,
        );
        final secondaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.secondaryColor,
          _seasonalController.nextTheme.secondaryColor,
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: secondaryColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              labelStyle: TextStyle(fontFamily: 'Nunito', color: primaryColor),
              alignLabelWithHint: maxLines > 1,
            ),
            maxLines: maxLines,
            style: TextStyle(
              fontFamily: 'Nunito',
              color: primaryColor.withBlue((primaryColor.blue * 0.9).toInt()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _seasonalController,
      builder: (context, child) {
        final backgroundGradient = _seasonalController.lerpGradient(
          _seasonalController.currentTheme.backgroundGradient,
          _seasonalController.nextTheme.backgroundGradient,
        );
        final primaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.primaryColor,
          _seasonalController.nextTheme.primaryColor,
        );
        final secondaryColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.secondaryColor,
          _seasonalController.nextTheme.secondaryColor,
        );
        final accentColor = _seasonalController.lerpColor(
          _seasonalController.currentTheme.accentColor,
          _seasonalController.nextTheme.accentColor,
        );

        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: backgroundGradient,
              ),
            ),
            child: Stack(
              children: [
                // Falling petals
                FallingPetals(seasonalController: _seasonalController),

                // Floating elements
                FloatingElements(seasonalController: _seasonalController),

                // Main content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Custom AppBar with seasonal theme
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 1000),
                          padding: const EdgeInsets.only(
                            top: 50,
                            bottom: 20,
                            left: 16,
                            right: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'Create Community',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _seasonalController.currentTheme.name,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedTree(
                                size: 40,
                                seasonalController: _seasonalController,
                              ),
                            ],
                          ),
                        ),

                        // Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildImagePicker(),
                                const SizedBox(height: 32),

                                // Name Field
                                _buildTextField(
                                  controller: nameController,
                                  label: 'Community Name',
                                  hint: 'e.g., The Urban Farm Collective',
                                ),

                                const SizedBox(height: 20),

                                // Description Field
                                _buildTextField(
                                  controller: descriptionController,
                                  label: 'Description',
                                  hint: 'Share your community vision...',
                                  maxLines: 4,
                                ),

                                const SizedBox(height: 40),

                                // Create Button
                                AnimatedButtonWrapper(
                                  seasonalController: _seasonalController,
                                  onTap: loading ? null : createCommunity,
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor,
                                          accentColor,
                                          primaryColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: loading
                                          ? null
                                          : createCommunity,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (loading)
                                            const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else
                                            const Icon(
                                              Icons.create,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          const SizedBox(width: 12),
                                          Text(
                                            loading
                                                ? 'Planting Your Community...'
                                                : 'Create Community',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Nunito',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Bottom decorative elements with seasonal trees
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    AnimatedTree(
                                      size: 60,
                                      seasonalController: _seasonalController,
                                    ),
                                    AnimatedTree(
                                      size: 80,
                                      seasonalController: _seasonalController,
                                    ),
                                    AnimatedTree(
                                      size: 60,
                                      seasonalController: _seasonalController,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
