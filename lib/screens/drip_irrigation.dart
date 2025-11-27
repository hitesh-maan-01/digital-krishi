// ignore_for_file: library_private_types_in_public_api, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';

// --------------------------------------------------------------------
// 1. CONTENT MODEL (The first step towards external JSON/API)
// --------------------------------------------------------------------

class GuideItem {
  final String title;
  final Widget content;
  final String? imageAssetPath; // Placeholder for image/diagram

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
}

// Placeholder for a loading state widget - Using a simple Fade Transition for smooth appearance
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
      color: EnhancedColors.accentLight,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w800, // Bolder title
            fontSize: 17,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
        iconColor: EnhancedColors.primaryGreen,
        collapsedIconColor: EnhancedColors.neutralTextDark,
        children: <Widget>[
          Divider(
            height: 1,
            thickness: 1,
            color: const Color.fromARGB(
              255,
              241,
              241,
              241,
            ), // Lighter, green-tinted divider
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image/Diagram Placeholder (for enhancing instructional value) ---
                  if (item.imageAssetPath != null) ...[
                    Image.asset(
                      item.imageAssetPath!,
                      // You can add properties like fit, height, width for better control
                      fit: BoxFit.cover,
                      height: 150, // Or adjust as needed
                    ),

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

// Helper function to build bulleted list items (needed for complex content)
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

// --------------------------------------------------------------------
// 3. MAIN SCREEN IMPLEMENTATION
// --------------------------------------------------------------------

class DripIrrigationScreen extends StatefulWidget {
  const DripIrrigationScreen({super.key});

  @override
  _DripIrrigationScreenState createState() => _DripIrrigationScreenState();
}

class _DripIrrigationScreenState extends State<DripIrrigationScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network delay with an elegant transition
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
        title: const Text('💧 Drip Irrigation Guide'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: EnhancedColors.primaryGreen,
        elevation: 1, // Slight elevation on AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0), // Increased padding
        child: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 700,
          ), // Smoother animation duration
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Use a combination of scale and fade for the content switch
            return FadeTransition(opacity: animation, child: child);
          },
          child: _isLoading ? const ShimmerGuideList() : _buildGuideContent(),
        ),
      ),
    );
  }

  Widget _buildGuideContent() {
    // Content is now generated from a list of GuideItem models
    final List<GuideItem> guideItems = [
      GuideItem(
        title: '💧 Key Benefits of Drip Irrigation',
        content: Text(
          'Drip irrigation delivers water directly to the plant roots, minimizing evaporation and runoff. This results in water savings of up to **50%**, reduced weed growth (as the surrounding soil stays dry), and healthier plants due to consistent moisture supply.',
          style: const TextStyle(
            fontSize: 15,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
      ),
      GuideItem(
        title: '⚙️ Filtration System Types',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              'Screen Filters: Best for well water or municipal sources with mainly sand/sediment.',
            ),
            _buildBulletPoint(
              'Disc Filters: Excellent for surface water containing organic matter, like algae or debris.',
            ),
            _buildBulletPoint(
              'Media Filters (Sand): The highest level of filtration, necessary for highly contaminated water sources.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🤖 Advanced and Automated Systems',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              'For larger farms, consider systems with automated timers and moisture sensors (IoT).',
            ),
            _buildBulletPoint(
              '**Automated Timers: Ensures precise, repeatable watering cycles based on time of day.',
            ),
            _buildBulletPoint(
              'Moisture Sensors: These devices measure soil water content and automatically trigger irrigation only when needed, maximizing efficiency.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🛠️ Essential System Components',
        imageAssetPath: 'assets/icons/irrigation.png', // Placeholder image
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBulletPoint(
              'Water Source & Mainline: The starting point that feeds the entire system.',
            ),
            _buildBulletPoint(
              'Filter & Pressure Regulator: Crucial for preventing clogs and maintaining uniform water flow.',
            ),
            _buildBulletPoint(
              'Mainline Tubing & Emitters: The delivery network that brings water directly to each plant.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🌍 Drip in Hydroponics & Vertical Farming',
        content: Text(
          'Drip irrigation is the most common method used in closed-loop hydroponic systems. It allows for the precise delivery of nutrient-rich water to the base of each plant, minimizing water usage and maximizing nutrient uptake in high-density, vertical environments.',
          style: const TextStyle(
            fontSize: 15,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
      ),
      GuideItem(
        title: '🥶 Winterization and Storage',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              'In regions with freezing temperatures, improper winterization can destroy your system.',
            ),
            _buildBulletPoint(
              'Flush: Thoroughly flush all lines and sub-mains to remove all standing water and sediment.',
            ),
            _buildBulletPoint(
              'Drain: Disconnect the entire system from the water source and drain all components, including filters and pressure regulators.',
            ),
            _buildBulletPoint(
              'Storage: Store control valves, filters, and other sensitive components indoors to prevent damage.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🌱 Simple DIY Setup Guide',
        content: Text(
          '1. Lay the Mainline: Connect the mainline tubing to your water source. 2. Install Emitters: Punch holes and insert emitters near each plant. 3. Secure the Tubing: Use stakes to keep the tubing in place. This simple process allows any farmer to implement a small-scale system easily.',
          style: const TextStyle(
            fontSize: 15,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
      ),
      GuideItem(
        title: '📅 Crop-Specific Scheduling (Advanced)',
        content: Text(
          'Irrigation needs vary significantly by crop type, soil structure, and the plant\'s growth stage. Scheduling must be tailored to these factors. Flowering and fruiting stages require the most consistent water volume to prevent yield loss.',
          style: const TextStyle(
            fontSize: 15,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
      ),
      GuideItem(
        title: '💧 Water Requirement Calculation (ET/Kc)',
        content: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 15,
              color: EnhancedColors.neutralTextDark,
            ),
            children: <TextSpan>[
              const TextSpan(
                text:
                    'The most accurate scheduling uses the Evapotranspiration (ET) method:\n',
              ),
              TextSpan(
                text:
                    'Crop Water Use = Reference ET (ETo) x Crop Coefficient (Kc).',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const TextSpan(
                text:
                    ' ETo is water lost from a reference surface, and Kc is a factor specific to your crop and its growth stage. This provides the **precise daily water volume** needed.',
              ),
            ],
          ),
        ),
      ),
      GuideItem(
        title: '🔍 Maintenance & Troubleshooting',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint('Clean filters weekly to prevent blockages.'),
            _buildBulletPoint(
              'Flush the lines periodically to remove sediment.',
            ),
            _buildBulletPoint(
              'In case of clogs, use a small wire to clear the emitter. Simple checks prevent major issues.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🎯 Types of Drip Emitters',
        imageAssetPath: 'assets/emitter_types.png', // Placeholder image
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              'Pressure-Compensating: Maintains uniform flow regardless of elevation, ideal for sloped terrain.',
            ),
            _buildBulletPoint(
              '**Adjustable Emitters: Allows you to manually change the flow rate for different plants.',
            ),
            _buildBulletPoint(
              'Non-Pressure Compensating: Best for flat land where uniform pressure is maintained.',
            ),
          ],
        ),
      ),
      GuideItem(
        title: '🧪 Fertilization with Drip (Fertigation)',
        content: Text(
          'Fertigation involves injecting liquid fertilizers directly into the drip lines. This method is highly efficient, as **nutrients are delivered precisely to the root zone**, reducing waste and nutrient runoff while improving plant uptake.',
          style: const TextStyle(
            fontSize: 15,
            color: EnhancedColors.neutralTextDark,
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Master the most efficient way to irrigate your crops, save water, and boost your yields.',
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

// Placeholder for Card Color (Added here for completeness)
extension CardColor on EnhancedColors {
  static const Color cardColor = Color.fromARGB(255, 255, 255, 255);
}
