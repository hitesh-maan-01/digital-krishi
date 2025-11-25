import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SowingCalendarPage extends StatefulWidget {
  const SowingCalendarPage({super.key});

  @override
  State<SowingCalendarPage> createState() => _SowingCalendarPageState();
}

class _SowingCalendarPageState extends State<SowingCalendarPage> {
  bool isLoading = true;
  bool isAscending = true;
  List<Map<String, dynamic>> allCrops = [];
  List<Map<String, dynamic>> filteredCrops = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      allCrops = [
        {
          "name": "Rice",
          "season": "June–July (Kharif), October–November (Rabi)",
          "imagePath": "assets/crops/rice.png",
          "monthList": [6, 7, 10, 11],
          "description":
              "Rice is the most consumed cereal after wheat, providing over half the daily calories for much of the world. Kerala mainly grows Oryza sativa varieties, which are well-adapted to the state’s climate. The plant grows 1–1.8 meters tall, with long slender leaves and branched panicles containing 50–300 flowers that produce the edible grains. Rice varieties for Kerala are suited to both Kharif and Rabi seasons, often grown in flooded fields. The crop’s plasticity and taste qualities make it a staple food for the region.",
        },
        {
          "name": "Tomato",
          "season": "September–December",
          "imagePath": "assets/crops/tomato.png",
          "monthList": [9, 10, 11, 12],
          "description":
              "Tomato is a popular warm-season vegetable in Kerala, valued for its high vitamin content and culinary versatility. It grows best in well-drained soil with regular moderate irrigation. The plant produces round, red fruits typically harvested from September to December. Disease-tolerant and high-yield varieties are suited for Kerala’s climate, supporting consistent production in home gardens and commercial fields.",
        },
        {
          "name": "Okra",
          "season": "February–March, June–July, October–November",
          "imagePath": "assets/crops/okra.png",
          "monthList": [2, 3, 6, 7, 10, 11],
          "description":
              "Okra thrives in Kerala’s warm climate and is cultivated throughout the year during key sowing windows. The plant bears long, green seed pods and requires moderate irrigation and warm temperatures. Okra is resistant to drought, making it suitable for many soil types. Regular harvesting encourages further pod production, and varieties in Kerala are chosen for their yield and pest resistance.",
        },
        {
          "name": "Pumpkin",
          "season": "January–March, May–June, September–December",
          "imagePath": "assets/crops/pumpkin.png",
          "monthList": [1, 2, 3, 5, 6, 9, 10, 11, 12],
          "description":
              "Pumpkin is widely grown in Kerala, valued for its high content of potassium, beta-carotene, and vitamin A. The plant is a vigorous climber preferring sandy loam soil and warm temperatures. Pumpkins are sown January–March or September–December; their orange flesh is rich in nutrients and antioxidants. Varieties are developed for resistance to fruit flies and high productivity. Regular irrigation, organic mulching, and pest management enhance yield and storage quality. [Read more](https://www.celkau.in/Crops/Vegetables/Pumpkin/pumpkin.aspx)",
        },
        {
          "name": "Cabbage",
          "season": "October–February",
          "imagePath": "assets/crops/cabbage.png",
          "monthList": [10, 11, 12, 1, 2],
          "description":
              "Cabbage is a cool-season crop grown mainly in Kerala’s high ranges. It prefers well-drained, sandy loam to clay soils with a pH of 6.0–6.5. The plant forms compact heads of thick, green leaves and requires careful irrigation and timely fertilization for optimal head formation. Regular weeding and pest management are needed to protect against moths, leaf webbers, borers, and aphids. Harvesting takes place 90–120 days after transplanting, with crops providing high yields when mature heads are promptly picked. [See details](https://www.celkau.in/Crops/Vegetables/Cabbage/cabbage.aspx)",
        },
        {
          "name": "Carrot",
          "season": "October–February",
          "imagePath": "assets/crops/carrot.png",
          "monthList": [10, 11, 12, 1, 2],
          "description":
              "Carrot is cultivated mainly in Kerala’s high altitude regions from August to January. The crop grows best in well-drained sandy loam soils with abundant organic matter. Proper irrigation, fertilization, and spacing are required for uniform root development and quality harvest.",
        },
        {
          "name": "Beetroot",
          "season": "October–February",
          "imagePath": "assets/crops/beetroot.png",
          "monthList": [10, 11, 12, 1, 2],
          "description":
              "Beetroot is grown in the cool regions of Kerala, favoring well-drained soils with neutral pH and good moisture retention. It requires timely irrigation and fertilizer application. Seeds are sown from August to January, and the crop matures in 60–75 days.",
        },
        {
          "name": "Spinach",
          "season": "All time except rainy season",
          "imagePath": "assets/crops/spinach.png",
          "monthList": [1, 2, 3, 4, 5, 6, 9, 10, 11, 12],
          "description":
              "Spinach is a leafy vegetable grown throughout the year in Kerala except during heavy monsoon rains. It thrives in loose, fertile soil with adequate moisture and requires partial shade to avoid heat stress.",
        },
        {
          "name": "Onion",
          "season": "December–March",
          "imagePath": "assets/crops/onion.png",
          "monthList": [12, 1, 2, 3],
          "description":
              "Onion is an important vegetable crop grown mainly during the dry season in Kerala. It requires well-drained, fertile soils and a cool climate for bulb formation. Crop management includes pest control and irrigation scheduling.",
        },
        {
          "name": "Beans",
          "season": "All time except rainy days",
          "imagePath": "assets/crops/beans.png",
          "monthList": [1, 2, 3, 4, 5, 6, 9, 10, 11, 12],
          "description":
              "Beans are grown year-round except during periods of heavy rain to prevent disease. They grow well in fertile, well-drained soil with adequate irrigation. The crop is valued for both fresh pods and dry seeds.",
        },
        {
          "name": "Snake Gourd",
          "season": "January–March, September–December",
          "imagePath": "assets/crops/snake_gourd.png",
          "monthList": [1, 2, 3, 9, 10, 11, 12],
          "description":
              "Snake gourd is a climbing vegetable that grows well in Kerala’s tropical climate. It prefers well-drained fertile soils and requires timely irrigation. The crop is susceptible to pests and diseases, which can be managed through integrated methods.",
        },
        {
          "name": "Maize",
          "season": "February–March, June–July",
          "imagePath": "assets/crops/maize.png",
          "monthList": [2, 3, 6, 7],
          "description":
              "Maize is a warm-season cereal grown extensively in Kerala during the Zaid and Kharif seasons. It prefers well-drained loam to sandy soils with good fertility. Maize requires moderate irrigation and is vulnerable to several pests such as stem borers, which require integrated pest management.",
        },
        {
          "name": "Brinjal",
          "season": "September–December",
          "imagePath": "assets/crops/brinjal.png",
          "monthList": [9, 10, 11, 12],
          "description":
              "Brinjal (eggplant) thrives in warm climates with well-drained fertile soil. It requires consistent watering and fertilization for healthy fruit development. Brinjal is susceptible to pests like fruit and shoot borer, which can be managed via cultural and biological control methods.",
        },
        {
          "name": "Cucumber",
          "season": "January–March, September–December",
          "imagePath": "assets/crops/cucumber.png",
          "monthList": [1, 2, 3, 9, 10, 11, 12],
          "description":
              "Cucumber grows well in Kerala during cooler and pre-monsoon seasons. It prefers sandy loam soils rich in organic matter with adequate moisture. Proper trellising and pest management, especially for powdery mildew, ensure good quality fruits.",
        },
        {
          "name": "Radish",
          "season": "October–February",
          "imagePath": "assets/crops/radish.png",
          "monthList": [10, 11, 12, 1, 2],
          "description":
              "Radish prefers cool and moist climates and sandy loam or loam soils. It grows well in Kerala’s high ranges during the winter months. Frequent irrigation and soil moisture maintenance are essential for crisp root development.",
        },
        {
          "name": "Green Chilli",
          "season": "May–June, August–September",
          "imagePath": "assets/crops/green_chilli.png",
          "monthList": [5, 6, 8, 9],
          "description":
              "Green chilli is a warm weather crop grown all over Kerala. It requires rich, well-drained soil and regular watering. Chilli plants are prone to diseases like leaf spot and pests like thrips, and should be carefully managed for optimal yield and quality.",
        },

        // Add other crops here following the same pattern...
      ];
      filteredCrops = List.from(allCrops);
      setState(() {
        isLoading = false;
      });
    });
  }

  void sortCrops() {
    filteredCrops.sort(
      (a, b) => isAscending
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']),
    );
    setState(() {});
  }

  void showCalendarDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enhanced Sowing Calendar'),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Crop')),
              for (var m = 1; m <= 12; m++)
                DataColumn(label: Text(_monthShort(m))),
            ],
            rows: allCrops.map((crop) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Image.asset(crop["imagePath"], width: 32, height: 32),
                        const SizedBox(width: 8),
                        Text(crop["name"]),
                      ],
                    ),
                  ),
                  for (var m = 1; m <= 12; m++)
                    DataCell(
                      crop['monthList'].contains(m)
                          ? const Icon(
                              Icons.event_available,
                              color: Colors.green,
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              selectionColor: Color.fromARGB(255, 5, 150, 105),
            ),
          ),
        ],
      ),
    );
  }

  void showCropDetail(Map<String, dynamic> crop) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Image.asset(crop['imagePath'], width: 40, height: 40),
            const SizedBox(width: 8),
            Text(crop['name']),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sowing Season: ${crop['season']}"),
              const SizedBox(height: 12),
              Text(crop['description']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String _monthShort(int m) => const [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 253, 244),
      appBar: AppBar(
        title: const Text("Sowing Calendar"),
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
        backgroundColor: const Color.fromARGB(255, 5, 150, 105),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: showCalendarDialog,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('View Calendar'),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isAscending
                        ? Icons.sort_by_alpha
                        : Icons.sort_by_alpha_outlined,
                  ),
                  tooltip: isAscending ? "Sort Ascending" : "Sort Descending",
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                      sortCrops();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? _buildShimmer()
                  : filteredCrops.isEmpty
                  ? const Center(child: Text('No crops available'))
                  : ListView.builder(
                      itemCount: filteredCrops.length,
                      itemBuilder: (context, index) {
                        final crop = filteredCrops[index];
                        return Card(
                          child: ListTile(
                            leading: Image.asset(
                              crop['imagePath'],
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.spa_rounded),
                            ),
                            title: Text(crop["name"]),
                            subtitle: Text(crop["season"]),
                            onTap: () => showCropDetail(crop),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 240, 253, 244), // ARGB base color
      highlightColor: const Color.fromARGB(
        255,
        5,
        150,
        105,
      ), // ARGB highlight color
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(
                255,
                240,
                253,
                244,
              ), // Base color for shimmer placeholder
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
