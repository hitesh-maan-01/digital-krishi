import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Scheme Data (Unchanged but included for completeness) ---

class Scheme {
  final String name;
  final String category;
  final String description; // includes criteria & benefits
  final String link;

  Scheme({
    required this.name,
    required this.category,
    required this.description,
    required this.link,
  });
}

final List<Scheme> allSchemes = [
  Scheme(
    name: "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
    category: "Subsidy",
    description:
        "Criteria: Land-holding farmers\n"
        "Benefits: ₹6,000/year in 3 installments via DBT\n"
        "Transfer directly to farmer's account.",
    link: "https://pmkisan.gov.in/",
  ),
  Scheme(
    name: "PM Kisan MaanDhan Yojana (PM-KMY)",
    category: "Pension",
    description:
        "Criteria: Small & Marginal Farmers, Age 18-40\n"
        "Benefits: Pension of ₹3,000/month after 60 years. Contributory scheme (₹55-200/month). Life Insurance Corporation (LIC) is pension fund manager.",
    link: "https://maandhan.in/",
  ),
  Scheme(
    name: "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
    category: "Insurance",
    description:
        "Criteria: All farmers\n"
        "Benefits: Crop insurance against natural risks (pre-sowing to post-harvest). Affordable premium. Coverage for notified crops.",
    link: "https://pmfby.gov.in/",
  ),
  Scheme(
    name: "Modified Interest Subvention Scheme (MISS)",
    category: "Subsidy",
    description:
        "Criteria: Farmers, Agri-entrepreneurs, FPOs, SHGs\n"
        "Benefits: Loans up to ₹2 Crores at subsidized interest (3% p.a.), for up to 25 projects. Credit guarantee coverage available.",
    link: "https://dmi.gov.in/",
  ),
  Scheme(
    name: "Paramparagat Krishi Vikas Yojana (PKVY)",
    category: "Organic",
    description:
        "Criteria: Clusters of minimum 20 farmers, up to 2 ha/farmer\n"
        "Benefits: Assistance of ₹31,500/ha for organic farming, includes incentives, capacity building, marketing support.",
    link: "https://pgsindia-ncof.gov.in/PKVY/index.aspx",
  ),
  Scheme(
    name: "Agriculture Infrastructure Fund (AIF)",
    category: "Infrastructure",
    description:
        "Criteria: Farmers, FPOs, SHGs, Startups, PACS, Co-ops\n"
        "Benefits: Financial support for post-harvest management, infrastructure (warehouses, cold chains), latest agri techniques.",
    link: "https://agriinfra.dac.gov.in/",
  ),
  Scheme(
    name: "SMAM (Sub-Mission on Agricultural Mechanization)",
    category: "Mechanization",
    description:
        "Criteria: Individuals, Groups, FPOs, SHGs\n"
        "Benefits: Subsidy for farm equipment, custom hiring centers, machinery banks. Awareness and capacity building activities.",
    link: "https://agrimachinery.nic.in/",
  ),
  Scheme(
    name: "Krishi UDAN Scheme",
    category: "Logistics",
    description:
        "Criteria: Farmers, exporters\n"
        "Benefits: Subsidized air freight for agri produce.",
    link: "https://www.aai.aero/en/business-opportunities/krishi-udan",
  ),
];

final categories = [
  "All",
  "Subsidy",
  "Insurance",
  "Pension",
  "Organic",
  "Infrastructure",
  "Mechanization",
  "Logistics",
];

// --- Schemes Page Widget ---

class SchemesPage extends StatefulWidget {
  const SchemesPage({super.key});

  @override
  _SchemesPageState createState() => _SchemesPageState();
}

class _SchemesPageState extends State<SchemesPage> {
  String selectedCategory = "All";
  late List<Scheme> filteredSchemes;
  final TextEditingController _searchController = TextEditingController();

  final Color primaryGreen = const Color.fromARGB(255, 5, 150, 105);
  final Color lightGreen = const Color.fromARGB(255, 230, 247, 240);
  final Color darkGrey = Colors.grey.shade700;

  @override
  void initState() {
    super.initState();
    filteredSchemes = allSchemes;
    _searchController.addListener(_search);
  }

  void _search() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSchemes = allSchemes.where((scheme) {
        final matchesCategory =
            selectedCategory == "All" || scheme.category == selectedCategory;
        final matchesText =
            scheme.name.toLowerCase().contains(query) ||
            scheme.description.toLowerCase().contains(query);
        return matchesCategory && matchesText;
      }).toList();
    });
  }

  void _filterByCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      _search(); // triggers text+category filtering
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Schemes"),
        backgroundColor: primaryGreen,
        // Improved: Subtle shadow for depth
        elevation: 2.0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 60, // Increased height for better visual spacing
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: categories
                  .map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (_) => _filterByCategory(cat),
                        labelStyle: TextStyle(
                          color: selectedCategory == cat
                              ? Colors.white
                              : darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                        // Improved: Consistent styling
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: primaryGreen,
                        // High-level: Use shape for modern look
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selectedCategory == cat
                                ? primaryGreen
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search by name or keyword",
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 5, 150, 105),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ), // Slightly less rounded for sleekness
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 10.0,
                ),
              ),
            ),
          ),
          // List of Schemes
          Expanded(
            child: filteredSchemes.isEmpty
                ? Center(
                    child: Text(
                      "No schemes found",
                      style: TextStyle(color: darkGrey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredSchemes.length,
                    itemBuilder: (context, index) {
                      final scheme = filteredSchemes[index];
                      return Card(
                        // Improved: Higher elevation and rounded corners
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16, // Increased horizontal margin
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            20,
                          ), // More internal padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Label (Tag Look)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      lightGreen, // Very light green background
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  scheme.category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Scheme Name (Higher prominence)
                              Text(
                                scheme.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900, // Extra bold
                                  fontSize: 22, // Larger size
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Description Text (More readable)
                              Text(
                                scheme.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: darkGrey, // Muted color
                                  height: 1.4, // Improved line spacing
                                ),
                              ),
                              const SizedBox(height: 15),

                              // Learn More Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text("Learn More"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    elevation: 2.0, // Subtle button elevation
                                  ),
                                  // Correct functionality: opens the external link
                                  onPressed: () async {
                                    final Uri url = Uri.parse(scheme.link);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      // Optional: Show error if the link can't be launched
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Could not open ${scheme.link}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
