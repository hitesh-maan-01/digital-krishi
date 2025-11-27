// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'market_api_service.dart';
import 'market_price_model.dart';
import 'crop_filter_widget.dart';

class MarketPricePage extends StatefulWidget {
  const MarketPricePage({super.key});

  @override
  State<MarketPricePage> createState() => _MarketPricePageState();
}

class _MarketPricePageState extends State<MarketPricePage> {
  List<MarketPrice> allPrices = [];
  List<MarketPrice> filteredPrices = [];

  bool isLoading = false;
  bool isSortedAlphabetically = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final data = await MarketApiService.fetchMarketPrices();
      setState(() {
        allPrices = data;
        filteredPrices = data;
      });
    } catch (e) {
      debugPrint("Error: $e");
      // Optionally, show a SnackBar or an error message to the user
    } finally {
      setState(() => isLoading = false);
    }
  }

  void applyFilters(String state, String city, String crop) {
    setState(() {
      filteredPrices = allPrices.where((price) {
        final matchState = state.isEmpty || price.state == state;
        final matchCity = city.isEmpty || price.market == city;
        final matchCrop = crop.isEmpty || price.commodity == crop;
        return matchState && matchCity && matchCrop;
      }).toList();

      // Re-apply sorting if it was active
      if (isSortedAlphabetically) {
        filteredPrices.sort((a, b) => a.commodity.compareTo(b.commodity));
      }
    });
  }

  void toggleSort() {
    setState(() {
      isSortedAlphabetically = !isSortedAlphabetically;
      if (isSortedAlphabetically) {
        filteredPrices.sort((a, b) => a.commodity.compareTo(b.commodity));
      } else {
        // Revert to original filter order (not the original fetched order)
        applyFilters('', '', ''); // This resets all filters to empty
      }
    });
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Market Prices",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 5, 150, 105),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSortedAlphabetically ? Icons.sort_by_alpha : Icons.sort,
                      color: const Color.fromARGB(255, 5, 150, 105),
                      size: 28,
                    ),
                    onPressed: allPrices.isEmpty ? null : toggleSort,
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: CropFilterWidget(
                  allPrices: allPrices,
                  onFilterChanged: applyFilters,
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? _buildLoadingShimmer()
                  : filteredPrices.isEmpty
                  ? const Center(
                      child: Text(
                        "No data found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPrices.length,
                      itemBuilder: (context, index) {
                        final price = filteredPrices[index];
                        return _buildPriceCard(price);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(MarketPrice price) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Card(
        key: ValueKey(price.commodity + price.market),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Name and Price in a single row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.commodity,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Variety: ${price.variety}",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${price.modalPrice.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Market and State in a separate row
              Text(
                "${price.market}, ${price.state}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
