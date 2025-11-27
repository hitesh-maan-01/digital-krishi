// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

// --------------------------------------------------------------------
// 1. CONTENT MODEL (The first step towards external JSON/API)
// --------------------------------------------------------------------

class GuideItem {
  final String title;
  final Widget content;
  final String? imageAssetPath;

  GuideItem({required this.title, required this.content, this.imageAssetPath});
}

// --------------------------------------------------------------------
// 2. UI COMPONENTS & COLORS
// --------------------------------------------------------------------

class EnhancedColors {
  static const Color primaryGreen = Color.fromARGB(
    255,
    33,
    150,
    83,
  ); // Modern Forest Green
  static const Color backgroundColor = Color.fromARGB(
    255,
    246,
    255,
    248,
  ); // Mint Off-White
  static const Color neutralTextDark = Color.fromARGB(
    255,
    29,
    53,
    35,
  ); // Dark Text
  static const Color accentLight = Color.fromARGB(
    255,
    178,
    223,
    191,
  ); // Light Accent for Dividers
  static const Color cardColor = Color.fromARGB(255, 255, 255, 255);
}

// Placeholder for a loading state widget
class ShimmerGuideList extends StatelessWidget {
  const ShimmerGuideList({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeIn,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(color: EnhancedColors.primaryGreen),
      ),
    );
  }
}

// Custom Card Style Implementation (ExpansionTile pattern)
class GuideCard extends StatelessWidget {
  final GuideItem item;

  const GuideCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // More pronounced shadow
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Rounded corners
      color: EnhancedColors.cardColor,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
        iconColor: EnhancedColors.primaryGreen,
        collapsedIconColor: EnhancedColors.neutralTextDark,
        children: <Widget>[
          Divider(height: 1, thickness: 1, color: EnhancedColors.accentLight),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image/Diagram Placeholder ---
                  if (item.imageAssetPath != null) ...[
                    Image.asset(
                      item.imageAssetPath!,
                      // You can add properties like fit, height, width for better control
                      fit: BoxFit.cover,
                      height: 150, // Or adjust as needed
                    ),
                    // Container(
                    //   height: 150,
                    //   color: EnhancedColors.accentLight.withOpacity(0.5),
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     'Diagram Placeholder: ${item.imageAssetPath!.split('/').last}',
                    //     style: TextStyle(
                    //       fontStyle: FontStyle.italic,
                    //       color: EnhancedColors.neutralTextDark,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 15),
                  ],
                  // --- Content ---
                  item.content,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to build bulleted list items
Widget _buildBulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, bottom: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '• ',
          style: TextStyle(fontSize: 15, color: EnhancedColors.neutralTextDark),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: EnhancedColors.neutralTextDark,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper function to build a paragraph
Widget _buildParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: EnhancedColors.neutralTextDark,
      ),
    ),
  );
}

// --------------------------------------------------------------------
// 3. MAIN SCREEN IMPLEMENTATION
// --------------------------------------------------------------------

class OrganicFarmingGuideScreen extends StatefulWidget {
  const OrganicFarmingGuideScreen({super.key});

  @override
  _OrganicFarmingGuideScreenState createState() =>
      _OrganicFarmingGuideScreenState();
}

class _OrganicFarmingGuideScreenState extends State<OrganicFarmingGuideScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedColors.backgroundColor,
      appBar: AppBar(
        title: const Text('🌿 Organic Farming Guide'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: EnhancedColors.primaryGreen,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _isLoading ? const ShimmerGuideList() : _buildGuideContent(),
        ),
      ),
    );
  }

  Widget _buildGuideContent() {
    final List<GuideItem> guideItems = [
      GuideItem(
        title: '🌿 Core Principles of Organic Farming',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Organic farming is a sustainable agricultural system that sustains the health of soils, ecosystems, and people. It relies on ecological processes, biodiversity, and cycles adapted to local conditions.',
            ),
            _buildParagraph(
              'It strictly prohibits the use of external inputs like synthetic fertilizers and chemical pesticides, focusing instead on **natural solutions**.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🌱 Soil Health: The Foundation',
        imageAssetPath:
            'assets/icons/fertilizer.png', // Placeholder image for context
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildParagraph(
              'The core principle is to feed the soil, not the plant. Key practices for building healthy soil include:',
            ),
            _buildBulletPoint(
              'Manure & Compost: Using aged animal manure and decomposed plant matter to build organic carbon.',
            ),
            _buildBulletPoint(
              'Cover Crops: Planting non-cash crops (e.g., legumes) to prevent erosion, suppress weeds, and **fix nitrogen**.',
            ),
            _buildBulletPoint(
              'Minimal Tillage: Reducing plowing frequency to protect soil structure, beneficial fungi, and microbial life.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🔄 Crop Rotation and Diversity',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Crop Rotation (never planting the same crop in the same field year after year) breaks pest and disease cycles and optimizes nutrient use.',
            ),
            _buildParagraph(
              'Diversity, such as intercropping (planting two or more crops together), improves ecosystem resilience and naturally boosts yields and pest resistance.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🌾 Seed Selection: Heirlooms and Non-GMO',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Organic farming relies exclusively on seeds that are not genetically modified (Non-GMO) and, ideally, organically grown.',
            ),
            _buildBulletPoint(
              'Heirloom Varieties: Often chosen for regional adaptation, disease resistance, and unique flavors.',
            ),
            _buildBulletPoint(
              'Open-Pollinated Seeds: Ensures farmers can save seeds year after year, building locally adapted genetics and reducing input costs.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '♻️ Building On-Farm Fertility Resources',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'The goal is to close the nutrient loop, minimizing the need for external inputs.',
            ),
            _buildBulletPoint(
              'Animal Integration: Using livestock manure as fertilizer, often rotated through fields.',
            ),
            _buildBulletPoint(
              '**Biochar: Using pyrolyzed organic material (charcoal) to permanently sequester carbon and increase soil water and nutrient holding capacity.',
            ),
            _buildBulletPoint(
              'Local Sourcing: If external inputs are needed, prioritizing locally sourced, approved organic materials.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '📈 Economic and Market Benefits',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'While yields might initially be lower, organic farming often results in higher profitability due to:',
            ),
            _buildBulletPoint(
              'Premium Pricing: Organic products often command higher prices in the market.',
            ),
            _buildBulletPoint(
              '**Reduced Input Costs: Eliminating expensive synthetic fertilizers and pesticides reduces operational expenses.',
            ),
            _buildBulletPoint(
              'Market Stability: Growing consumer demand ensures a stable and expanding market for organic produce.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '💧 Water Conservation and Management',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Organic systems naturally conserve water due to high soil organic matter, but specific techniques are key:',
            ),
            _buildBulletPoint(
              'Mulching: Thick layers of organic material reduce evaporation and stabilize soil temperature.',
            ),
            _buildBulletPoint(
              'Keyline Design: Using strategic plowing or earthworks to slow down water runoff and encourage infiltration.',
            ),
            _buildBulletPoint(
              'Dry Farming: Techniques used in semi-arid areas that rely solely on stored soil moisture, typically requiring specific crop selection.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🐞 Natural Pest & Disease Control',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Organic pest management relies on biological controls and cultural practices:',
            ),
            _buildBulletPoint(
              'Biological Control: Introducing or attracting beneficial insects (like ladybugs or parasitic wasps) that prey on pests.',
            ),
            _buildBulletPoint(
              'Cultural Control: Timely planting, using pest-resistant varieties, and ensuring optimal plant spacing.',
            ),
            _buildBulletPoint(
              'Approved Sprays: Using natural substances like **Neem oil** or **Bacillus thuringiensis (Bt)** as a targeted, last resort.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🧪 Natural Nutrient Sources (Fertilizer)',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'Since synthetic fertilizers are prohibited, organic nutrients come from:',
            ),
            _buildBulletPoint(
              'Green Manures: Crops grown specifically to be incorporated back into the soil, adding biomass and nutrients.',
            ),
            _buildBulletPoint(
              'Compost Tea: Liquid fertilizer made by steeping compost, beneficial for immediate nutrient delivery and microbial activity.',
            ),
            _buildBulletPoint(
              'Mineral Powders: Naturally mined minerals like rock phosphate or gypsum to address specific soil deficiencies.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '📜 The Certification Process',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
              'To market products as "organic," farms must be certified by a recognized body. This involves a rigorous, multi-step process:',
            ),
            _buildBulletPoint(
              '**Transition Period: Typically 3 years where no prohibited substances are used on the land before certification can be granted.',
            ),
            _buildBulletPoint(
              '**Annual Inspection: Mandatory yearly visits by a third-party certifier to verify compliance.',
            ),
            _buildBulletPoint(
              'Record-Keeping: Meticulous documentation of all inputs, seeds, harvests, and sales is required to ensure traceability.',
            ),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A comprehensive guide to growing healthy crops naturally, focusing on soil life and ecological balance.',
          style: TextStyle(fontSize: 16, color: EnhancedColors.neutralTextDark),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 20),
        ...guideItems.map((item) => GuideCard(item: item)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}
