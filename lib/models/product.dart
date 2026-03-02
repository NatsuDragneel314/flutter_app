class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String category;
  final double rating;
  final int reviews;
  final int stock;
  final String emoji;
  final List<String> tags;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.stock,
    required this.emoji,
    required this.tags,
    this.isFavorite = false,
  });

  double get discountPercent =>
      ((originalPrice - price) / originalPrice * 100).roundToDouble();

  bool get hasDiscount => originalPrice > price;
}
