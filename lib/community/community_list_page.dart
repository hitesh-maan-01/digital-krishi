// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

import '../Authentication/login_page.dart';
import 'community_create_page.dart';
import 'community_detail_page.dart';

// Seasonal Theme Data
class SeasonalTheme {
  final String name;
  final List<Color> gradientColors;
  final List<Color> cardColors;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> petalColors;
  final IconData seasonIcon;
  final String seasonEmoji;

  const SeasonalTheme({
    required this.name,
    required this.gradientColors,
    required this.cardColors,
    required this.primaryColor,
    required this.accentColor,
    required this.petalColors,
    required this.seasonIcon,
    required this.seasonEmoji,
  });
}

class SeasonalThemes {
  static const List<SeasonalTheme> themes = [
    // Spring - Fresh Growth
    SeasonalTheme(
      name: 'Spring Bloom',
      gradientColors: [Color(0xFFF8FBF6), Color(0xFFE8F5E8), Color(0xFFE1F5FE)],
      cardColors: [Color(0xFFFFFFFF), Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
      primaryColor: Color(0xFF4CAF50),
      accentColor: Color(0xFF81C784),
      petalColors: [
        Color(0xFF4CAF50),
        Color(0xFF8BC34A),
        Color(0xFFCDDC39),
        Color(0xFFFFEB3B),
      ],
      seasonIcon: Icons.local_florist,
      seasonEmoji: '🌸',
    ),

    // Summer - Vibrant Life
    SeasonalTheme(
      name: 'Summer Harvest',
      gradientColors: [Color(0xFFFFF8E1), Color(0xFFFFF3C4), Color(0xFFFFE0B2)],
      cardColors: [Color(0xFFFFFFFF), Color(0xFFFFFDE7), Color(0xFFFFF8E1)],
      primaryColor: Color(0xFFFF9800),
      accentColor: Color(0xFFFFB74D),
      petalColors: [
        Color(0xFFFF9800),
        Color(0xFFFFB74D),
        Color(0xFFFFD54F),
        Color(0xFFFFE082),
      ],
      seasonIcon: Icons.wb_sunny,
      seasonEmoji: '☀️',
    ),

    // Autumn - Warm Harvest
    SeasonalTheme(
      name: 'Autumn Harvest',
      gradientColors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2), Color(0xFFFFCCBC)],
      cardColors: [Color(0xFFFFFFFF), Color(0xFFFFF8E1), Color(0xFFFFECB3)],
      primaryColor: Color(0xFFFF5722),
      accentColor: Color(0xFFFF8A65),
      petalColors: [
        Color(0xFFFF5722),
        Color(0xFFFF7043),
        Color(0xFFFFAB40),
        Color(0xFFFF8F00),
      ],
      seasonIcon: Icons.eco,
      seasonEmoji: '🍂',
    ),

    // Winter - Cool Rest
    SeasonalTheme(
      name: 'Winter Rest',
      gradientColors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
      cardColors: [Color(0xFFFFFFFF), Color(0xFFF3E5F5), Color(0xFFE1F5FE)],
      primaryColor: Color(0xFF2196F3),
      accentColor: Color(0xFF64B5F6),
      petalColors: [
        Color(0xFF2196F3),
        Color(0xFF42A5F5),
        Color(0xFF64B5F6),
        Color(0xFF81C784),
      ],
      seasonIcon: Icons.ac_unit,
      seasonEmoji: '❄️',
    ),

    // Monsoon - Life Giving
    SeasonalTheme(
      name: 'Monsoon Growth',
      gradientColors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
      cardColors: [Color(0xFFFFFFFF), Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
      primaryColor: Color(0xFF388E3C),
      accentColor: Color(0xFF66BB6A),
      petalColors: [
        Color(0xFF388E3C),
        Color(0xFF4CAF50),
        Color(0xFF66BB6A),
        Color(0xFF81C784),
      ],
      seasonIcon: Icons.water_drop,
      seasonEmoji: '🌧️',
    ),
  ];
}

// Enhanced Seasonal Falling Petals Animation
class SeasonalFallingPetalsAnimation extends StatefulWidget {
  final SeasonalTheme currentTheme;

  const SeasonalFallingPetalsAnimation({super.key, required this.currentTheme});

  @override
  State<SeasonalFallingPetalsAnimation> createState() =>
      _SeasonalFallingPetalsAnimationState();
}

class _SeasonalFallingPetalsAnimationState
    extends State<SeasonalFallingPetalsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SeasonalPetal> _petals = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _controller.addListener(_updatePetals);
  }

  void _updatePetals() {
    // Add new petals occasionally
    if (_random.nextDouble() < 0.15) {
      _petals.add(
        _SeasonalPetal(
          x: _random.nextDouble() * MediaQuery.of(context).size.width,
          y: -30,
          size: 8 + _random.nextDouble() * 12,
          rotation: _random.nextDouble() * 2 * pi,
          speed: 0.8 + _random.nextDouble() * 1.2,
          color:
              widget.currentTheme.petalColors[_random.nextInt(
                widget.currentTheme.petalColors.length,
              )],
          opacity: 0.3 + _random.nextDouble() * 0.4,
          rotationSpeed: 0.01 + _random.nextDouble() * 0.02,
          drift: _random.nextDouble() * 2 - 1,
        ),
      );
    }

    // Remove off-screen petals
    _petals.removeWhere(
      (petal) => petal.y > MediaQuery.of(context).size.height + 50,
    );

    // Update petal positions
    for (var petal in _petals) {
      petal.y += petal.speed;
      petal.x += sin(petal.y * 0.005) * petal.drift;
      petal.rotation += petal.rotationSpeed;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(painter: _SeasonalPetalsPainter(petals: _petals)),
    );
  }
}

class _SeasonalPetal {
  double x, y, size, rotation, speed, opacity, rotationSpeed, drift;
  Color color;

  _SeasonalPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.color,
    required this.opacity,
    required this.rotationSpeed,
    required this.drift,
  });
}

class _SeasonalPetalsPainter extends CustomPainter {
  final List<_SeasonalPetal> petals;
  _SeasonalPetalsPainter({required this.petals});

  @override
  void paint(Canvas canvas, Size size) {
    for (var petal in petals) {
      final paint = Paint()
        ..color = petal.color.withValues(alpha: petal.opacity)
        ..style = PaintingStyle.fill;

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);

      canvas.save();
      canvas.translate(petal.x, petal.y);
      canvas.rotate(petal.rotation);

      // Draw shadow
      canvas.drawCircle(
        Offset(petal.size / 4, petal.size / 4),
        petal.size / 3,
        shadowPaint,
      );

      // Draw petal shape
      final path = Path()
        ..moveTo(petal.size / 2, 0)
        ..quadraticBezierTo(
          petal.size * 0.8,
          petal.size * 0.3,
          petal.size,
          petal.size * 0.8,
        )
        ..quadraticBezierTo(
          petal.size * 0.6,
          petal.size * 1.2,
          petal.size / 2,
          petal.size,
        )
        ..quadraticBezierTo(
          petal.size * 0.4,
          petal.size * 1.2,
          0,
          petal.size * 0.8,
        )
        ..quadraticBezierTo(
          petal.size * 0.2,
          petal.size * 0.3,
          petal.size / 2,
          0,
        );

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage>
    with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> communitiesFuture;
  late final AnimationController _staggerController;
  late final AnimationController _seasonController;
  late final AnimationController _pulseController;

  // Add these search-related variables
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _currentSeasonIndex = 0;
  SeasonalTheme get _currentTheme => SeasonalThemes.themes[_currentSeasonIndex];

  @override
  void initState() {
    super.initState();
    communitiesFuture = _fetchCommunities();

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Seasonal transition controller
    _seasonController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Start seasonal cycling
    _startSeasonalCycle();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
    });
  }

  void _startSeasonalCycle() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _cycleSeason();
      }
    });
  }

  void _cycleSeason() {
    _seasonController.forward().then((_) {
      if (mounted) {
        setState(() {
          _currentSeasonIndex =
              (_currentSeasonIndex + 1) % SeasonalThemes.themes.length;
        });
        _seasonController.reset();

        // Schedule next season change
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _cycleSeason();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _seasonController.dispose();
    _pulseController.dispose();
    _searchController.dispose(); // Add this line
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchCommunities() async {
    final response = await supabase.from('communities').select();
    return (response as List).cast<Map<String, dynamic>>();
  }

  void _refreshList() {
    setState(() {
      communitiesFuture = _fetchCommunities();
    });
    _staggerController.reset();
    _staggerController.forward();
  }

  // Add this new method
  List<Map<String, dynamic>> _filterCommunities(
    List<Map<String, dynamic>> communities,
  ) {
    if (_searchQuery.isEmpty) {
      return communities;
    }
    return communities.where((community) {
      final name = (community['name'] ?? '').toString().toLowerCase();
      final description = (community['description'] ?? '')
          .toString()
          .toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const LoginPage(),
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log out'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEnhancedCommunityCard(
    Map<String, dynamic> community,
    int index,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_staggerController, _seasonController]),
      builder: (context, child) {
        final slideAnimation = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            1.0,
            curve: Curves.elasticOut,
          ),
        );

        return Transform.translate(
          offset: Offset(0, 50 * (1 - slideAnimation.value)),
          child: Transform.scale(
            scale: 0.5 + (0.5 * slideAnimation.value),
            child: Opacity(
              opacity: slideAnimation.value.clamp(0.0, 1.0),
              child: _EnhancedCommunityCard(
                community: community,
                index: index,
                theme: _currentTheme,
                seasonAnimation: _seasonController,
                onRefresh: _refreshList, // Add this line
                onTap: () async {
                  final refreshed = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, _, _) =>
                          CommunityDetailPage(community: community),
                      transitionsBuilder: (_, animation, __, child) =>
                          SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                    ),
                  );
                  if (refreshed == true) _refreshList();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _seasonController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _currentTheme.gradientColors[0],
          body: Stack(
            children: [
              // Animated seasonal background
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _currentTheme.gradientColors,
                  ),
                ),
              ),

              // Seasonal falling petals
              SeasonalFallingPetalsAnimation(currentTheme: _currentTheme),

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Seasonal App Bar
                  SliverAppBar(
                    expandedHeight: 220.0,
                    floating: false,
                    pinned: true,
                    elevation: 8,
                    backgroundColor: _currentTheme.primaryColor,
                    foregroundColor: Colors.white,
                    actions: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) => Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: IconButton(
                            icon: Icon(
                              _isSearching ? Icons.close : Icons.search,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching;
                                if (!_isSearching) {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }
                              });
                            },
                            tooltip: _isSearching
                                ? "Close Search"
                                : "Search Communities",
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) => Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.1),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ),
                            onPressed: _logout,
                            tooltip: "Logout",
                          ),
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: AnimatedContainer(
                        duration: const Duration(seconds: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _currentTheme.primaryColor,
                              _currentTheme.primaryColor.withValues(alpha: 0.8),
                              _currentTheme.accentColor,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🌤 Top-left Theme Name & Tagline
                              Row(
                                children: [
                                  Icon(
                                    _currentTheme.seasonIcon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(seconds: 1),
                                    child: Text(
                                      _currentTheme.name,
                                      key: ValueKey(_currentTheme.name),
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Connect • Grow • Thrive',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentTheme.seasonEmoji,
                                style: const TextStyle(fontSize: 18),
                              ),

                              const Spacer(),

                              // 🌾 Bottom Center Main Title
                              Center(
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) => Transform.scale(
                                    scale:
                                        1.0 + (_pulseController.value * 0.05),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _currentTheme.seasonEmoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Farm Communities',
                                          style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(1, 1),
                                                blurRadius: 3,
                                                color: Colors.black26,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Add Search Bar
                  if (_isSearching)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _currentTheme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search communities...',
                            hintStyle: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: _currentTheme.primaryColor,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: FutureBuilder<List<Map<String, dynamic>>>(
                      future: communitiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 100),
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) =>
                                        Transform.scale(
                                          scale:
                                              1.0 +
                                              (_pulseController.value * 0.2),
                                          child: CircularProgressIndicator(
                                            color: _currentTheme.primaryColor,
                                            strokeWidth: 4,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Growing communities...',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: _currentTheme.primaryColor
                                          .withValues(alpha: 0.8),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 100),
                                  Icon(
                                    Icons.error_outline_rounded,
                                    size: 80,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Failed to load communities',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.data?.isEmpty ?? true) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 100),
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) =>
                                        Transform.scale(
                                          scale:
                                              1.0 +
                                              (_pulseController.value * 0.1),
                                          child: Icon(
                                            _currentTheme.seasonIcon,
                                            size: 80,
                                            color: _currentTheme.primaryColor
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'No communities in this season yet',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: _currentTheme.primaryColor
                                          .withValues(alpha: 0.8),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Plant the first seed! ${_currentTheme.seasonEmoji}',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Filter communities based on search query
                          final allCommunities = snapshot.data!;
                          final filteredCommunities = _filterCommunities(
                            allCommunities,
                          );

                          // Show "no results" if search returns empty
                          if (filteredCommunities.isEmpty &&
                              _searchQuery.isNotEmpty) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 100),
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) =>
                                          Transform.scale(
                                            scale:
                                                1.0 +
                                                (_pulseController.value * 0.1),
                                            child: Icon(
                                              Icons.search_off,
                                              size: 80,
                                              color: _currentTheme.primaryColor
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No communities found',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        color: _currentTheme.primaryColor
                                            .withValues(alpha: 0.8),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try searching for "$_searchQuery"',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          // Show filtered results
                          return SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.8,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildEnhancedCommunityCard(
                                filteredCommunities[index],
                                index,
                              ),
                              childCount: filteredCommunities.length,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // Seasonal FAB
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: FloatingActionButton.extended(
                        onPressed: () async {
                          final created = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, _, ___) =>
                                  const CommunityCreatePage(),
                              transitionsBuilder: (_, animation, __, child) =>
                                  SlideTransition(
                                    position:
                                        Tween<Offset>(
                                          begin: const Offset(0, 1),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.elasticOut,
                                          ),
                                        ),
                                    child: child,
                                  ),
                            ),
                          );
                          if (created == true) _refreshList();
                        },
                        icon: Icon(
                          _currentTheme.seasonIcon,
                          color: Colors.white,
                          size: 24,
                        ),
                        label: Text(
                          'Plant Community ${_currentTheme.seasonEmoji}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                            fontSize: 16,
                          ),
                        ),
                        backgroundColor: _currentTheme.primaryColor,
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Enhanced Community Card with Seasonal Theming
class _EnhancedCommunityCard extends StatefulWidget {
  final Map<String, dynamic> community;
  final int index;
  final SeasonalTheme theme;
  final Animation<double> seasonAnimation;
  final VoidCallback onTap;
  final VoidCallback onRefresh; // Add this

  const _EnhancedCommunityCard({
    required this.community,
    required this.index,
    required this.theme,
    required this.seasonAnimation,
    required this.onTap,
    required this.onRefresh, // Add this
  });

  @override
  State<_EnhancedCommunityCard> createState() => _EnhancedCommunityCardState();
}

class _EnhancedCommunityCardState extends State<_EnhancedCommunityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 24.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _hoverController.forward(),
      onTapUp: (_) => _hoverController.reverse(),
      onTapCancel: () => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_hoverController, widget.seasonAnimation]),
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedContainer(
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.theme.cardColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add three-dot menu at top-right
                    Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_vert,
                          color: widget.theme.primaryColor.withValues(
                            alpha: 0.6,
                          ),
                          size: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) async {
                          if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Delete Community?',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: widget.theme.primaryColor,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete "${widget.community['name']}"? This action cannot be undone.',
                                  style: const TextStyle(fontFamily: 'Nunito'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await Supabase.instance.client
                                    .from('communities')
                                    .delete()
                                    .eq('id', widget.community['id']);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Community deleted successfully',
                                      ),
                                      backgroundColor:
                                          widget.theme.primaryColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  widget.onRefresh();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to delete community',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Community Icon with seasonal colors - tappable
                    Hero(
                      tag:
                          'community_${widget.community['id']}_${widget.index}',
                      child: GestureDetector(
                        onTap: widget.community['image_url']?.isNotEmpty == true
                            ? () {
                                showDialog(
                                  context: context,
                                  barrierColor: Colors.black87,
                                  builder: (context) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(20),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 4.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                widget.community['image_url'],
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                      color: widget
                                                          .theme
                                                          .primaryColor,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            40,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Icon(
                                                            Icons.error_outline,
                                                            color: Colors.white,
                                                            size: 64,
                                                          ),
                                                          SizedBox(height: 12),
                                                          Text(
                                                            'Failed to load image',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              tooltip: 'Close',
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Pinch to zoom',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.8),
                                                  fontSize: 12,
                                                  fontFamily: 'Nunito',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 2),
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.theme.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                                widget.theme.accentColor.withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: widget.theme.primaryColor.withValues(
                                alpha: 0.5,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child:
                              widget.community['image_url']?.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    widget.community['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildSeasonalIcon(),
                                  ),
                                )
                              : _buildSeasonalIcon(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Community Name with seasonal styling
                    Text(
                      widget.community['name'] ?? 'Untitled',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.theme.primaryColor.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Expanded(
                      child: Text(
                        widget.community['description'] ??
                            'Growing together in ${widget.theme.name.toLowerCase()}...',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.grey[600],
                          fontSize: 12,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Seasonal Join Button
                    AnimatedContainer(
                      duration: const Duration(seconds: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.theme.primaryColor,
                            widget.theme.accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.theme.primaryColor.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.theme.seasonIcon,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Join',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonalIcon() {
    return Icon(
      widget.theme.seasonIcon,
      size: 36,
      color: widget.theme.primaryColor.withValues(alpha: 0.8),
    );
  }
}
