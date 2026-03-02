import 'dart:async';
import '../models/product.dart';

/// Simulates a Django REST API with fake product data.
/// In production, replace with real http.get() calls to your Django backend.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Fake product database (mimics Django's /api/products/) ──
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'AirPods Pro Max',
      description:
          'Premium wireless over-ear headphones with active noise cancellation, spatial audio, and 30-hour battery life.',
      price: 89.99,
      originalPrice: 129.99,
      category: 'Electronics',
      rating: 4.8,
      reviews: 2341,
      stock: 15,
      emoji: '🎧',
      tags: ['Wireless', 'ANC', 'Premium'],
      isFavorite: true,
    ),
    Product(
      id: 2,
      name: 'Mechanical Keyboard',
      description:
          'Compact 75% layout mechanical keyboard with RGB backlight, hot-swap switches, and aluminum body.',
      price: 155.00,
      originalPrice: 155.00,
      category: 'Electronics',
      rating: 4.6,
      reviews: 987,
      stock: 30,
      emoji: '⌨️',
      tags: ['RGB', 'Mechanical', 'Compact'],
    ),
    Product(
      id: 3,
      name: 'Minimalist Watch',
      description:
          'Scandinavian design with a genuine leather strap, sapphire crystal glass, and 5 ATM water resistance.',
      price: 299.00,
      originalPrice: 399.00,
      category: 'Fashion',
      rating: 4.9,
      reviews: 512,
      stock: 8,
      emoji: '⌚',
      tags: ['Leather', 'Sapphire', 'Premium'],
      isFavorite: true,
    ),
    Product(
      id: 4,
      name: 'Laptop Stand',
      description:
          'Adjustable aluminum laptop stand with cable management, foldable design, and fits 10–17 inch laptops.',
      price: 39.99,
      originalPrice: 59.99,
      category: 'Accessories',
      rating: 4.5,
      reviews: 1820,
      stock: 50,
      emoji: '💻',
      tags: ['Aluminum', 'Foldable', 'Ergonomic'],
    ),
    Product(
      id: 5,
      name: 'Running Sneakers',
      description:
          'Lightweight carbon-fiber plate running shoes with responsive foam midsole and breathable knit upper.',
      price: 120.00,
      originalPrice: 160.00,
      category: 'Sports',
      rating: 4.7,
      reviews: 3200,
      stock: 22,
      emoji: '👟',
      tags: ['Carbon Plate', 'Lightweight', 'Breathable'],
    ),
    Product(
      id: 6,
      name: 'Coffee Grinder',
      description:
          'Burr grinder with 40 grind settings, 300g bean hopper, and stainless steel conical burrs for consistent grind.',
      price: 79.00,
      originalPrice: 79.00,
      category: 'Kitchen',
      rating: 4.4,
      reviews: 764,
      stock: 18,
      emoji: '☕',
      tags: ['Burr', 'Conical', 'Stainless'],
    ),
    Product(
      id: 7,
      name: 'Yoga Mat Pro',
      description:
          'Extra-thick 6mm non-slip yoga mat with alignment lines, carrying strap, and eco-friendly TPE material.',
      price: 45.00,
      originalPrice: 65.00,
      category: 'Sports',
      rating: 4.6,
      reviews: 1432,
      stock: 40,
      emoji: '🧘',
      tags: ['Eco-friendly', 'Non-slip', '6mm'],
    ),
    Product(
      id: 8,
      name: 'Smart Water Bottle',
      description:
          'Insulated stainless steel bottle with hydration reminders, temperature display, and 24hr cold retention.',
      price: 34.99,
      originalPrice: 49.99,
      category: 'Accessories',
      rating: 4.3,
      reviews: 2100,
      stock: 60,
      emoji: '🧊',
      tags: ['Insulated', 'Smart', 'Stainless'],
    ),
    Product(
      id: 9,
      name: 'LED Desk Lamp',
      description:
          'Eye-caring LED desk lamp with 5 color modes, touch dimmer, USB charging port, and flexible arm.',
      price: 52.00,
      originalPrice: 75.00,
      category: 'Electronics',
      rating: 4.5,
      reviews: 630,
      stock: 25,
      emoji: '💡',
      tags: ['LED', 'Dimmable', 'USB Port'],
    ),
    Product(
      id: 10,
      name: 'Leather Backpack',
      description:
          'Full-grain leather backpack with 20L capacity, padded laptop sleeve, and antique brass hardware.',
      price: 189.00,
      originalPrice: 249.00,
      category: 'Fashion',
      rating: 4.8,
      reviews: 345,
      stock: 12,
      emoji: '🎒',
      tags: ['Full-grain', 'Laptop Sleeve', 'Brass'],
      isFavorite: true,
    ),
  ];

  // GET /api/products/ — fetch all products (with optional delay to simulate network)
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_products);
  }

  // GET /api/products/?category=X
  Future<List<Product>> fetchByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (category == 'All') return List.from(_products);
    return _products.where((p) => p.category == category).toList();
  }

  // GET /api/products/search/?q=X
  Future<List<Product>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  // GET /api/products/:id/
  Future<Product?> fetchProduct(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // PATCH /api/products/:id/favorite/
  Future<void> toggleFavorite(int id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].isFavorite = !_products[index].isFavorite;
    }
  }

  List<String> get categories =>
      ['All', ..._products.map((p) => p.category).toSet().toList()..sort()];
}
