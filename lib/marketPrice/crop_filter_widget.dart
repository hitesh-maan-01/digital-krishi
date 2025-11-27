// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'market_price_model.dart';

class CropFilterWidget extends StatefulWidget {
  final List<MarketPrice> allPrices; // Use a list of the full data model
  final Function(String, String, String) onFilterChanged;

  const CropFilterWidget({
    super.key,
    required this.allPrices,
    required this.onFilterChanged,
  });

  @override
  _CropFilterWidgetState createState() => _CropFilterWidgetState();
}

class _CropFilterWidgetState extends State<CropFilterWidget> {
  String? selectedState;
  String? selectedCity;
  String? selectedCrop;

  List<String> states = [];
  List<String> cities = [];
  List<String> crops = [];

  @override
  void initState() {
    super.initState();
    // Initialize the states list from the full data
    states = widget.allPrices.map((e) => e.state).toSet().toList()..sort();
  }

  void onStateChanged(String? newState) {
    setState(() {
      selectedState = newState;
      // Reset city and crop when a new state is selected
      selectedCity = null;
      selectedCrop = null;

      if (newState != null) {
        // Filter cities based on the selected state
        cities =
            widget.allPrices
                .where((price) => price.state == newState)
                .map((e) => e.market)
                .toSet()
                .toList()
              ..sort();
      } else {
        // If no state is selected, clear cities
        cities = [];
      }
      crops = []; // Clear crops when state changes
    });
    // Call the parent's filter function with the new selection
    widget.onFilterChanged(
      selectedState ?? '',
      selectedCity ?? '',
      selectedCrop ?? '',
    );
  }

  void onCityChanged(String? newCity) {
    setState(() {
      selectedCity = newCity;
      // Reset crop when a new city is selected
      selectedCrop = null;

      if (selectedState != null && newCity != null) {
        // Filter crops based on the selected state and city
        crops =
            widget.allPrices
                .where(
                  (price) =>
                      price.state == selectedState && price.market == newCity,
                )
                .map((e) => e.commodity)
                .toSet()
                .toList()
              ..sort();
      } else {
        // If no city is selected, clear crops
        crops = [];
      }
    });
    widget.onFilterChanged(
      selectedState ?? '',
      selectedCity ?? '',
      selectedCrop ?? '',
    );
  }

  void onCropChanged(String? newCrop) {
    setState(() {
      selectedCrop = newCrop;
    });
    widget.onFilterChanged(
      selectedState ?? '',
      selectedCity ?? '',
      newCrop ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // State Dropdown
        _buildDropdown(
          hint: "Select State",
          value: selectedState,
          items: states,
          onChanged: onStateChanged,
        ),
        const SizedBox(height: 12),
        // City Dropdown (conditionally enabled)
        _buildDropdown(
          hint: "Select City",
          value: selectedCity,
          items: cities,
          onChanged: selectedState != null ? onCityChanged : null,
          enabled: selectedState != null && cities.isNotEmpty,
        ),
        const SizedBox(height: 12),
        // Crop Dropdown (conditionally enabled)
        _buildDropdown(
          hint: "Select Crop",
          value: selectedCrop,
          items: crops,
          onChanged: selectedCity != null ? onCropChanged : null,
          enabled: selectedCity != null && crops.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?)? onChanged,
    bool enabled = true,
  }) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(
        ignoring: !enabled,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.green.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
