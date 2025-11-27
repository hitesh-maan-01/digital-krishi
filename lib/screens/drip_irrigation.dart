import 'package:flutter/material.dart';

// Placeholder for a loading state widget
class ShimmerGuideList extends StatelessWidget {
  const ShimmerGuideList({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _DripIrrigationScreenState.primaryGreen,
      ),
    );
  }
}

// Custom Card Style Implementation (ExpansionTile pattern)
class GuideCard extends StatelessWidget {
  final String title;
  // NOTE: Changed back to String content to adhere to the pattern of the provided 'drip_irrigation.dart' content structure.
  final String content;

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
        // Style the title to match the dark text in the screenshot
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _DripIrrigationScreenState.neutralTextDark,
          ),
        ),
        iconColor: _DripIrrigationScreenState
            .primaryGreen, // Use primary green for the arrow icon
        collapsedIconColor: _DripIrrigationScreenState.neutralTextDark,
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
              child: Text(
                content,
                // Use the defined neutral text color for better readability
                style: const TextStyle(
                  fontSize: 15,
                  color: _DripIrrigationScreenState.neutralTextDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// MAIN SCREEN IMPLEMENTATION
// ====================================================================

class DripIrrigationScreen extends StatefulWidget {
  const DripIrrigationScreen({super.key});

  @override
  _DripIrrigationScreenState createState() => _DripIrrigationScreenState();
}

class _DripIrrigationScreenState extends State<DripIrrigationScreen> {
  // Define the custom colors based on the ARGB values
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Drip Irrigation Guide'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(
            255,
            255,
            255,
            255,
          ), // White back icon and title
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Explicitly ensure back icon is white
        ),
        backgroundColor: primaryGreen,
        elevation: 0, // Modern flat AppBar look
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
    // NOTE: Content strings from the original code are maintained, and new advanced feature cards are added.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Master the most efficient way to irrigate your crops, save water, and boost your yields.',
          style: TextStyle(fontSize: 16, color: neutralTextDark),
          textAlign:
              TextAlign.start, // Align text to start for better readability
        ),
        const SizedBox(height: 20),

        // --- 💧 Key Benefits ---
        GuideCard(
          title: '💧 Key Benefits of Drip Irrigation',
          content:
              'Drip irrigation delivers water directly to the plant roots, minimizing evaporation and runoff. This results in water savings of up to 50%, reduced weed growth (as the surrounding soil stays dry), and healthier plants due to consistent moisture supply.',
        ),

        // --- 🛠️ Essential System Components ---
        GuideCard(
          title: '🛠️ Essential System Components',
          content:
              'A basic drip system includes a water source(tap or tank), a filter to prevent clogs, a pressure regulator to control flow, mainline tubing, and emitters or drippers that deliver water to each plant. Understanding these components is the first step to a successful setup.',
        ),

        // --- 🌱 Simple DIY Setup Guide ---
        GuideCard(
          title: '🌱 Simple DIY Setup Guide',
          content:
              '**1. Lay the Mainline:** Connect the mainline tubing to your water source. **2. Install Emitters:** Punch holes and insert emitters near each plant. **3. Secure the Tubing:** Use stakes to keep the tubing in place. This simple process allows any farmer to implement a small-scale system easily.',
        ),

        // --- 📅 Crop-Specific Scheduling (NEW ADVANCED FEATURE) ---
        GuideCard(
          title: '📅 Crop-Specific Scheduling',
          content:
              'Irrigation needs vary significantly by crop type, soil structure (clay vs. sandy), and the plant\'s growth stage. Scheduling must be tailored to these factors. For example, the flowering and fruiting stages require the most consistent water volume to prevent yield loss.',
        ),

        // --- 💧 Water Requirement Calculator (ET/Kc) (NEW ADVANCED FEATURE) ---
        GuideCard(
          title: '💧 Water Requirement Calculator (ET/Kc)',
          content:
              'The most accurate scheduling uses the Evapotranspiration (ET) method: **Crop Water Use = Reference ET (ETo) x Crop Coefficient (Kc)**. ETo is the water lost from a standard surface, and Kc is a factor specific to your crop and its growth stage. This provides the precise daily water volume needed.',
        ),

        // --- 🔍 Maintenance & Troubleshooting ---
        GuideCard(
          title: '🔍 Maintenance & Troubleshooting',
          content:
              'Regular maintenance is key to a long-lasting system. **Clean filters** weekly to prevent blockages. **Flush the lines** periodically to remove sediment. In case of clogs, use a small wire to clear the emitter. Simple checks can prevent major issues.',
        ),

        // --- ⚠️ Pressure Loss Diagnostics (NEW ADVANCED FEATURE) ---
        GuideCard(
          title: '⚠️ Pressure Loss Diagnostics',
          content:
              'Low pressure is the most common system failure. Always check pressure gauges at the filter inlet and the end of the line. A significant drop (over 15%) across the filter indicates it needs cleaning. Low end-of-line pressure usually means the main line or lateral line length exceeds design specifications.',
        ),

        // --- 🤖 Advanced & Automated Systems ---
        GuideCard(
          title: '🤖 Advanced & Automated Systems',
          content:
              'For larger farms, consider advanced systems with **automated timers** and **moisture sensors (IoT)**. These systems can be controlled via your phone, ensuring your crops get the exact amount of water they need, when they need it, with minimal human intervention.',
        ),

        // --- 🎯 Types of Drip Emitters ---
        GuideCard(
          title: '🎯 Types of Drip Emitters',
          content:
              'Choosing the right emitter is crucial. **Pressure-compensating emitters** maintain a uniform flow rate regardless of elevation changes, ideal for sloped terrain. **Adjustable emitters** allow you to manually change the flow rate for different plants, while simple **non-pressure compensating emitters** are best for flat land.',
        ),

        // --- 🧪 Fertilization with Drip (Fertigation) ---
        GuideCard(
          title: '🧪 Fertilization with Drip (Fertigation)',
          content:
              'Drip irrigation systems can be used for fertigation, which involves injecting liquid fertilizers directly into the drip lines. This method is highly efficient, as nutrients are delivered precisely to the root zone, reducing waste and nutrient runoff.',
        ),

        // --- 📈 Drip vs. Traditional Irrigation ---
        GuideCard(
          title: '📈 Drip vs. Traditional Irrigation',
          content:
              'Compared to traditional flood irrigation or sprinklers, drip irrigation saves significantly on water and labor. It also reduces disease by keeping plant leaves dry and prevents nutrient loss. While the initial setup cost may be higher, the long-term savings are substantial.',
        ),

        // --- 📐 Sizing Your System ---
        GuideCard(
          title: '📐 Sizing Your System',
          content:
              'Properly sizing your system is vital. You need to calculate the total water requirements (gallons or liters per hour) for your plants and match it to the flow rate of your main water source. This ensures uniform water distribution across all your crops.',
        ),

        // --- ☀️ Solar-Powered Drip Systems ---
        GuideCard(
          title: '☀️ Solar-Powered Drip Systems',
          content:
              'For farms in remote areas, a solar-powered drip system is a sustainable solution. A small solar panel can power a pump that draws water from a well or tank, providing a reliable and eco-friendly water supply for your crops without a constant electricity source.',
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
