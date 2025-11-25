import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Define a reusable guide card widget
class GuideCard extends StatelessWidget {
  final String title;
  final String content;

  const GuideCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: const Color.fromARGB(255, 5, 150, 105),
        textColor: const Color.fromARGB(255, 5, 150, 105),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Define a reusable widget for the shimmer loading effect
class ShimmerGuideList extends StatelessWidget {
  const ShimmerGuideList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 5, 150, 105),
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          5,
          (index) => Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: CircleAvatar(radius: 20, backgroundColor: Colors.white),
              title: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 12.0,
                  width: 150.0,
                  child: ColoredBox(color: Colors.white),
                ),
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 10.0,
                  width: double.infinity,
                  child: ColoredBox(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
