import 'package:flutter/material.dart';

class OrganicFarmingGuideScreen extends StatefulWidget {
  const OrganicFarmingGuideScreen({super.key});

  @override
  _OrganicFarmingGuideScreenState createState() =>
      _OrganicFarmingGuideScreenState();
}

class _OrganicFarmingGuideScreenState extends State<OrganicFarmingGuideScreen> {
  // Define the custom colors (same as Drip Irrigation for consistency)
  static const Color primaryGreen = Color.fromARGB(
    255,
    5,
    150,
    105,
  ); // Emerald Green
  static const Color backgroundColor = Color.fromARGB(
    255,
    240,
    253,
    244,
  ); // Light Green/White background
  static const Color neutralTextDark = Color.fromARGB(
    255,
    40,
    40,
    40,
  ); // Dark text for high contrast

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
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
            style: TextStyle(fontSize: 15, color: neutralTextDark),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: neutralTextDark),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a paragraph (simulating original string content)
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: neutralTextDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Organic Farming Guide'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255), // White title
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // White back icon
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isLoading ? const ShimmerGuideList() : _buildGuideContent(),
        ),
      ),
    );
  }

  Widget _buildGuideContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A comprehensive guide to growing healthy crops naturally, focusing on soil life and ecological balance.',
          style: TextStyle(fontSize: 16, color: neutralTextDark),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 20),

        // 1. Core Principles
        GuideCard(
          title: '🌿 Core Principles of Organic Farming',
          // Content is now a Widget (Column)
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'Organic farming is a sustainable agricultural system that sustains the health of soils, ecosystems, and people. It relies on ecological processes, biodiversity, and cycles adapted to local conditions.',
              ),
              _buildParagraph(
                'It strictly prohibits the use of external inputs like synthetic fertilizers and chemical pesticides, focusing instead on natural solutions.',
              ),
            ],
          ),
        ),

        // 2. Soil Health (The Foundation)
        GuideCard(
          title: '🌱 Soil Health: The Foundation',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'The core principle is to feed the soil, not the plant. Key practices for building healthy soil include:',
              ),
              _buildBulletPoint(
                '* Manure & Compost: Using aged animal manure and decomposed plant matter to build organic carbon.',
              ),
              _buildBulletPoint(
                '* Cover Crops: Planting non-cash crops (e.g., legumes, grasses) to prevent erosion, suppress weeds, and fix nitrogen.',
              ),
              _buildBulletPoint(
                '* Minimal Tillage: Reducing plowing frequency to protect soil structure, beneficial fungi, and microbial life.',
              ),
            ],
          ),
        ),

        // 3. Crop Rotation & Diversity
        GuideCard(
          title: '🔄 Crop Rotation and Diversity',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'Rotating crops (never planting the same crop in the same field year after year) is essential. It breaks pest and disease cycles and optimizes nutrient use by following heavy feeders with nitrogen fixers.',
              ),
              _buildParagraph(
                '* Diversity, such as intercropping (planting two or more crops together), improves ecosystem resilience and naturally boosts yields and pest resistance.',
              ),
            ],
          ),
        ),

        // 4. Natural Pest & Disease Management
        GuideCard(
          title: '🐞 Natural Pest & Disease Control',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'Organic pest management relies on biological controls and cultural practices:',
              ),
              _buildBulletPoint(
                '* Biological Control: Introducing or attracting beneficial insects (like ladybugs or parasitic wasps) that prey on pests.',
              ),
              _buildBulletPoint(
                '* Cultural Control: Timely planting, using pest-resistant varieties, and ensuring optimal plant spacing for good air circulation.',
              ),
              _buildBulletPoint(
                '* Approved Sprays: Using natural substances like **Neem oil** or **Bacillus thuringiensis (Bt)** as a targeted, last resort.',
              ),
            ],
          ),
        ),

        // 5. Natural Nutrient Sources (Fertilizer)
        GuideCard(
          title: '🧪 Natural Nutrient Sources (Fertilizer)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'Since synthetic fertilizers are prohibited, organic nutrients come from:',
              ),
              _buildBulletPoint(
                '* Green Manures: Crops grown specifically to be incorporated back into the soil, adding biomass and nutrients.',
              ),
              _buildBulletPoint(
                '* Compost Tea: Liquid fertilizer made by steeping compost, beneficial for immediate nutrient delivery and microbial activity.',
              ),
              _buildBulletPoint(
                '* Mineral Powders: Naturally mined minerals like rock phosphate or gypsum to address specific soil deficiencies without chemical processing.',
              ),
            ],
          ),
        ),

        // 6. Weed Management
        GuideCard(
          title: '🌾 Weed Management Methods',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'Controlling weeds without chemical herbicides requires a proactive approach:',
              ),
              _buildBulletPoint(
                '* Mulching: Applying thick layers of organic material (straw, wood chips) to block sunlight and suppress weed growth.',
              ),
              _buildBulletPoint(
                '* Mechanical Cultivation: Using machinery (rotary hoes) or hand tools to physically cut or uproot weeds.',
              ),
              _buildBulletPoint(
                '* Solarization/Occultation: Using plastic sheets to heat the soil or block light, killing weeds before planting.',
              ),
            ],
          ),
        ),

        // 7. Organic Certification
        GuideCard(
          title: '📜 The Certification Process',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'To market products as "organic," farms must be certified by a recognized body. This involves a rigorous, multi-step process.',
              ),
              _buildBulletPoint(
                '* Transition Period: Typically 3 years where no prohibited substances are used on the land before certification can be granted.',
              ),
              _buildBulletPoint(
                '* Annual Inspection: Mandatory yearly visits by a third-party certifier to verify compliance.',
              ),
              _buildBulletPoint(
                '* Record-Keeping: Meticulous documentation of all inputs, seeds, harvests, and sales is required to ensure traceability.',
              ),
            ],
          ),
        ),

        // 8. Economic Benefits
        GuideCard(
          title: '💰 Economic Benefits of Organic Farming',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParagraph(
                'While yields might initially be lower, organic farming often results in higher profitability due to:',
              ),
              _buildBulletPoint(
                '* Premium Pricing: Organic products often command higher prices in the market.',
              ),
              _buildBulletPoint(
                '* Reduced Input Costs: Eliminating expensive synthetic fertilizers and pesticides reduces operational expenses.',
              ),
              _buildBulletPoint(
                '* Market Stability: Growing consumer demand ensures a stable and expanding market for organic produce.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ====================================================================
// UI PLACEHOLDERS (Must be outside the State class to be public/static)
// ====================================================================

// Placeholder for a loading state widget
class ShimmerGuideList extends StatelessWidget {
  const ShimmerGuideList({super.key});
  @override
  Widget build(BuildContext context) {
    // Reference the state class for colors
    return const Center(
      child: CircularProgressIndicator(
        color: _OrganicFarmingGuideScreenState.primaryGreen,
      ),
    );
  }
}

// Custom Card Style Implementation (ExpansionTile pattern)
class GuideCard extends StatelessWidget {
  final String title;

  final Widget content;

  const GuideCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    // Card color set to white/light for the clean, contrasting look
    return Card(
      elevation: 3, // Subtle shadow for a modern lift
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _OrganicFarmingGuideScreenState.neutralTextDark,
          ),
        ),
        // Reference the state class for colors
        iconColor: _OrganicFarmingGuideScreenState.primaryGreen,
        collapsedIconColor: _OrganicFarmingGuideScreenState.neutralTextDark,
        children: <Widget>[
          const Divider(
            height: 1,
            thickness: 1,
            color: Color.fromARGB(25, 0, 0, 0),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: content, // Now renders the complex Widget content
            ),
          ),
        ],
      ),
    );
  }
}
