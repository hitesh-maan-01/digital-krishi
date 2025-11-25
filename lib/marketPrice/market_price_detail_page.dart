// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../marketPrice/market_price_model.dart';

// class MarketPriceDetailPage extends StatelessWidget {
//   final MarketPrice price;

//   const MarketPriceDetailPage({super.key, required this.price});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("${price.commodity} - ${price.market}"),
//         backgroundColor: const Color.fromARGB(255, 5, 150, 105),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Current Price: ₹${price.modalPrice.toStringAsFixed(2)}",
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             const Text(
//               "Price Trend (Last 7 Days)",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),

//             SizedBox(
//               height: 240,
//               child: LineChart(
//                 LineChartData(
//                   //swapAnimationDuration: const Duration(milliseconds: 800),
//                   //swapAnimationCurve: Curves.easeInOut,
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             "Day ${value.toInt() + 1}",
//                             style: const TextStyle(fontSize: 10),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   gridData: FlGridData(show: true),
//                   borderData: FlBorderData(show: true),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: price.last7Days
//                           .asMap()
//                           .entries
//                           .map((e) => FlSpot(e.key.toDouble(), e.value))
//                           .toList(),
//                       isCurved: true,
//                       color: const Color.fromARGB(255, 5, 150, 105),
//                       barWidth: 3,
//                       belowBarData: BarAreaData(
//                         show: true,
//                         gradient: LinearGradient(
//                           colors: [
//                             const Color.fromARGB(
//                               255,
//                               5,
//                               150,
//                               105,
//                             ).withOpacity(0.4),
//                             Colors.transparent,
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (spot, _, __, ___) {
//                           return FlDotCirclePainter(
//                             radius: 4,
//                             color: Colors.white,
//                             strokeWidth: 2,
//                             strokeColor: const Color.fromARGB(255, 5, 150, 105),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                   lineTouchData: LineTouchData(
//                     enabled: true,
//                     touchTooltipData: LineTouchTooltipData(
//                       //tooltipBgColor: Colors.grey.shade200,
//                       getTooltipItems: (touchedSpots) {
//                         return touchedSpots.map((spot) {
//                           return LineTooltipItem(
//                             "Day ${spot.x.toInt() + 1}\n₹${spot.y.toStringAsFixed(2)}",
//                             const TextStyle(color: Colors.black, fontSize: 12),
//                           );
//                         }).toList();
//                       },
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
