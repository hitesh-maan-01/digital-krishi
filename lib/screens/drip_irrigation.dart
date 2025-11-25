import 'package:flutter/material.dart';

// ====================================================================
// PLACEHOLDER WIDGETS (To make the main screen code runnable)
// ====================================================================

// Placeholder for a loading state widget
class ShimmerGuideList extends StatelessWidget {
  const ShimmerGuideList({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// Placeholder for the GuideCard widget structure (simulating the ExpansionTile functionality)
class GuideCard extends StatelessWidget {
  final String title;
  // CRITICAL FIX: Changed content type to Widget to accept Column/Text
  final Widget content; 

  const GuideCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Subtle lift for modern look
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: <Widget>[
          // Add a line separator for visual clarity when expanded
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: content,
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
  // Define the updated custom colors as static const
  static const Color primaryGreen = Color.fromARGB(255, 5, 150, 105); // #059669
  static const Color backgroundColor = Color.fromARGB(255, 240, 253, 244); // #F0FDF4
  static const Color accentOrange = Color.fromARGB(255, 255, 165, 0); // #FFA500
  static const Color neutralTextDark = Color.fromARGB(255, 40, 40, 40); // #282828
  // Fixed Pro Tip background color (FFA500 with ~15% opacity)
  static const Color proTipBackground = Color.fromARGB(40, 255, 165, 0); 


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
  
  // Helper function for the Pro Tip UI element
  Widget buildProTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: proTipBackground, 
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: accentOrange, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Pro Tip: $text',
                style: const TextStyle(
                  fontSize: 14,
                  color: neutralTextDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Drip Irrigation Guide'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Ensure back button is white
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
        // Introduction and Visual Divider
        const Text(
          'Master the most efficient way to irrigate your crops, save water, and boost your yields.',
          style: TextStyle(fontSize: 16, color: neutralTextDark),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 10),
        Container(
          height: 3, 
          width: 60,
          decoration: BoxDecoration(
            color: accentOrange, // Use accent color for emphasis
            borderRadius: BorderRadius.circular(2)
          ),
        ),
        const SizedBox(height: 20),

        // --- 💧 Key Benefits ---
        GuideCard(
          title: '💧 Key Benefits',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Drip irrigation delivers water directly to the plant roots, minimizing evaporation and runoff. Key benefits include:\n\n'
                '* Water savings of up to **50%**\n'
                '* Reduced weed growth (as the surrounding soil stays dry)\n'
                '* Healthier plants due to consistent moisture supply',
                style: TextStyle(color: neutralTextDark),
              ),
              buildProTip('Drip systems save up to 50% of water compared to traditional methods!'),
            ],
          ),
        ),

        // --- 🛠️ System Components ---
        GuideCard(
          title: '🛠️ System Components',
          content:
              const Text('A basic drip system includes:\n\n'
              '* **Water Source:** Tap or tank\n'
              '* **Filter:** Crucial to prevent clogs\n'
              '* **Pressure Regulator:** To control flow\n'
              '* **Mainline Tubing**\n'
              '* **Emitters/Drippers:** Delivers water to each plant\n\n'
              '**Tip:** Always use Gaskets or Teflon Tape on threaded connections to prevent common leaks.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),

        // --- 🌱 Simple DIY Setup Guide ---
        GuideCard(
          title: '🌱 DIY Setup Guide',
          content:
              const Text('1. Lay the Mainline:** Connect the mainline tubing to your water source.\n'
              '2. Install Emitters:** Punch holes and insert emitters near each plant. For row crops, consider using **drip tape** (thin tubing with built-in emitters).\n'
              '3. Secure the Tubing:** Use stakes to keep the tubing in place.\n\n'
              'This simple process allows any farmer to implement a small-scale system easily.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),
        
        // --- 🔍 Maintenance & Troubleshooting ---
        GuideCard(
          title: '🔍 Maintenance & Troubleshooting',
          content:
              const Text('Regular maintenance is key to a long-lasting system:\n\n'
              '* **Clean filters** weekly to prevent blockages.\n'
              '* **Flush the lines** periodically to remove sediment.\n'
              '* In case of clogs, use a small wire to clear the emitter.\n\n'
              'Simple checks can prevent major issues and downtime.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),

        // --- 🤖 Automated Systems ---
        GuideCard(
          title: '🤖 Automated Systems',
          content:
              const Text('For larger farms, consider systems with **automated timers** and **moisture sensors**. These advanced systems can be controlled via your phone, ensuring your crops get the exact amount of water they need, minimizing human intervention.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),
        
        // --- 🎯 Types of Drip Emitters ---
        GuideCard(
          title: '🎯 Types of Emitters',
          content:
              const Text('Choosing the right emitter is crucial:\n\n'
              '* **Pressure-Compensating Emitters:** Maintain uniform flow regardless of elevation. Ideal for sloped terrain.\n'
              '* **Adjustable Emitters:** Allow manual flow rate changes for different plants.\n'
              '* **Non-Pressure Compensating:** Best for flat land and simple setups.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),

        // --- 🧪 Fertilization with Drip (Fertigation) ---
        GuideCard(
          title: '🧪 Fertigation (Adding Fertilizer)',
          content:
              const Text('Fertigation involves injecting liquid fertilizers directly into the drip lines. This method is highly efficient, as nutrients are delivered precisely to the root zone, significantly reducing waste and nutrient runoff compared to broadcasting.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),

        // --- 💧 Water Quality & Testing ---
        GuideCard(
          title: '🧪 Water Quality & Testing',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Water quality is critical for drip systems. Hard water (high calcium/magnesium) requires specific, higher-grade filtration to prevent emitter clogging. Regularly test your water:\n\n'
                '* **pH Level:** Extremely acidic or alkaline water can damage components.\n'
                '* **Mineral Content:** High minerals indicate the need for better filters.\n\n'
                'Regular testing prevents long-term maintenance headaches.',
                style: TextStyle(color: neutralTextDark),
              ),
              buildProTip('Acidic (low pH) water can be treated with neutralizing filters to protect your equipment and ensure nutrient uptake.'),
            ],
          ),
        ),

        // --- 📈 Drip vs. Traditional Irrigation ---
        GuideCard(
          title: '📈 Drip vs. Traditional',
          content:
              const Text('Drip irrigation is superior to traditional flood or sprinklers. It offers:\n\n'
              '* Significantly higher water and labor savings.\n'
              '* Reduced disease by keeping plant leaves dry.\n'
              '* Prevents nutrient loss.\n\n'
              'While the initial setup cost is higher, the long-term Return on Investment (ROI) is substantial.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),

        // --- 📐 Sizing Your System ---
        GuideCard(
          title: '📐 Sizing Your System',
          content:
              const Text('Properly sizing your system is vital. You must:\n\n'
              '1.  Calculate the total water requirement (Liters/Hour) for all your plants.\n'
              '2.  Match this to the maximum flow rate of your main water source.\n\n'
              'This ensures uniform water distribution across all your crops and prevents pressure drops.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),
        
        // --- ☀️ Solar-Powered Drip Systems ---
        GuideCard(
          title: '☀️ Solar-Powered Drip',
          content:
              const Text('For farms in remote areas without reliable grid access, a solar-powered drip system is a sustainable solution. A small solar panel can power a pump that draws water from a well or tank, providing a reliable and eco-friendly water supply for your crops.',
              style: TextStyle(color: neutralTextDark),
              ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}