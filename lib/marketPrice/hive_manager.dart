// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart';
// import '../marketPrice/market_price_model.dart';

// class HiveManager {
//   static const String boxName = "market_prices";

//   static Future<void> initHive() async {
//     final dir = await getApplicationDocumentsDirectory();
//     Hive.init(dir.path);
//   }

//   static Future<void> savePrices(List<MarketPrice> prices) async {
//     //final box = await Hive.openBox(boxName);
//     // final jsonList = prices.map((p) => p.toJson()).toList();
//     // await box.put('prices', jsonList);
//   }

//   static Future<List<MarketPrice>> getPrices() async {
//     final box = await Hive.openBox(boxName);
//     final jsonList = box.get('prices', defaultValue: []);
//     return (jsonList as List)
//         .map((json) => MarketPrice.fromJson(Map<String, dynamic>.from(json)))
//         .toList();
//   }

//   static Future<void> clearPrices() async {
//     final box = await Hive.openBox(boxName);
//     await box.clear();
//   }
// }
