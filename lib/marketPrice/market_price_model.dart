class MarketPrice {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final double modalPrice;
  final String arrivalDate;

  const MarketPrice({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.modalPrice,
    required this.arrivalDate,
  });

  /// Creates a new [MarketPrice] instance from a JSON map.
  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      market: json['market'] as String? ?? '',
      commodity: json['commodity'] as String? ?? '',
      variety: json['variety'] as String? ?? '',
      modalPrice: double.tryParse(json['modal_price']?.toString() ?? '0') ?? 0,
      arrivalDate: json['arrival_date'] as String? ?? '',
    );
  }

  /// Converts this [MarketPrice] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'district': district,
      'market': market,
      'commodity': commodity,
      'variety': variety,
      'modal_price': modalPrice.toString(),
      'arrival_date': arrivalDate,
    };
  }

  /// Creates a copy of this object with optional new values.
  MarketPrice copyWith({
    String? state,
    String? district,
    String? market,
    String? commodity,
    String? variety,
    double? modalPrice,
    String? arrivalDate,
  }) {
    return MarketPrice(
      state: state ?? this.state,
      district: district ?? this.district,
      market: market ?? this.market,
      commodity: commodity ?? this.commodity,
      variety: variety ?? this.variety,
      modalPrice: modalPrice ?? this.modalPrice,
      arrivalDate: arrivalDate ?? this.arrivalDate,
    );
  }
}
