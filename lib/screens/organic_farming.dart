import 'package:flutter/material.dart';
import 'package:digital_krishi/widgets/guide_card.dart';

class OrganicFarmingScreen extends StatefulWidget {
  const OrganicFarmingScreen({super.key});

  @override
  _OrganicFarmingScreenState createState() => _OrganicFarmingScreenState();
}

class _OrganicFarmingScreenState extends State<OrganicFarmingScreen> {
  // Define the custom colors based on the ARGB values
  static const Color primaryGreen = Color.fromARGB(255, 5, 150, 105);
  static const Color backgroundColor = Color.fromARGB(255, 240, 253, 244);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network delay to showcase the shimmer effect
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
        title: const Text('Organic Farming Guide'),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
        backgroundColor: primaryGreen,
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
          'A comprehensive guide to building a healthy, sustainable, and chemical-free farm ecosystem.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        GuideCard(
          title: '🌱 Advanced Soil Health & Fertility',
          content:
              'Go beyond basic compost. Implement vermicomposting using earthworms to produce rich, organic fertilizer. Introduce biofertilizers and bio-stimulants to enhance nutrient absorption and support a thriving microbial ecosystem in the soil. A living soil is the cornerstone of sustainable agriculture.',
        ),
        GuideCard(
          title: '🐛 Integrated Pest Management (IPM)',
          content:
              'Instead of broad-spectrum pesticides, adopt IPM. This holistic approach includes using natural predators (e.g., ladybugs), botanical pesticides like neem oil, and installing physical barriers. The goal is to manage pests below a damaging threshold, not to eliminate them entirely.',
        ),
        GuideCard(
          title: '🤝 Polyculture and Companion Planting',
          content:
              'Embrace biodiversity by practicing "polyculture" (growing multiple crops together) instead of monoculture. Use "companion planting" to pair crops that benefit each other. For example, planting basil near tomatoes can repel pests, while planting beans can fix nitrogen in the soil, benefiting neighboring plants.',
        ),
        GuideCard(
          title: '♻️ Resource & Waste Management',
          content:
              'Minimize waste through efficient resource use. Create closed-loop systems by converting all farm waste into compost, feed, or bioenergy. This reduces external inputs and makes the farm self-sustaining. Consider **rainwater harvesting** and **drip irrigation** for water conservation.',
        ),
        GuideCard(
          title: '🌾 Natural Fertilizers & Amendments',
          content:
              'Utilize natural sources to enrich your soil. **Bone meal** provides phosphorus, **fish emulsion** offers nitrogen, and **seaweed extract** is rich in micronutrients. These amendments improve soil structure and provide balanced nutrition for your plants without synthetic chemicals.',
        ),
        GuideCard(
          title: '📜 Organic Certification & Standards',
          content:
              'Understand the value of organic certification. It guarantees that your produce is grown without prohibited substances and according to strict organic standards. This builds consumer trust and allows you to market your products as premium, certified organic goods.',
        ),
        GuideCard(
          title: '🧬 Seed Saving & Heirloom Varieties',
          content:
              'Preserve genetic diversity by saving seeds from your best plants. Focus on **heirloom** and **open-pollinated** varieties, which produce seeds that are true-to-type. This practice reduces costs and allows you to breed crops that are well-adapted to your local climate and soil.',
        ),
        GuideCard(
          title: '🐔 Integrated Livestock Farming',
          content:
              'Integrate animals into your farm\'s ecosystem. Chickens can be used for pest control and weeding, while their droppings serve as a valuable source of nitrogen-rich manure. Managed grazing by livestock can also improve soil health and fertility.',
        ),
        GuideCard(
          title: '🔪 Weeding & Tillage Strategies',
          content:
              'Instead of herbicides, manage weeds through non-chemical means. Techniques like **mulching** with straw or wood chips, **solarization** (covering soil with plastic to kill weeds with solar heat), and **no-till farming** help control weeds while preserving soil structure and health.',
        ),
      ],
    );
  }
}
