// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'market_price_model.dart';

class MarketApiService {
  static const String baseUrl =
      "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070";
  static const String apiKey =
      "579b464db66ec23bdd000001562b571ba6034b325dc0fd19701d8e7a"; // Replace with your valid key

  static Future<List<MarketPrice>> fetchMarketPrices() async {
    final uri = Uri.parse("$baseUrl?api-key=$apiKey&format=json&limit=70000");

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['records'] == null) {
        return [];
      }

      return (data['records'] as List)
          .map((e) => MarketPrice.fromJson(e))
          .toList();
    } else {
      throw Exception(
        "Failed to fetch market prices. Status: ${response.statusCode}",
      );
    }
  }
}
