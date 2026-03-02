import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Product> products;
  final void Function(Product) onToggleFav;

  const FavoritesScreen(
      {super.key, required this.products, required this.onToggleFav});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final CartService _cart = CartService();

  List<Product> get _favorites =>
      widget.products.where((p) => p.isFavorite).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                const Text('Saved Items',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_favorites.length}',
                      style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          if (_favorites.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🤍', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    const Text('No saved items yet',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    Text('Tap ♡ on any product to save it',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[500])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: _favorites.length,
                itemBuilder: (_, i) {
                  final p = _favorites[i];
                  return ProductCard(
                    product: p,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: p,
                          cart: _cart,
                          onToggleFav: () {
                            widget.onToggleFav(p);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    onAddToCart: () => _cart.addToCart(p),
                    onToggleFav: () {
                      widget.onToggleFav(p);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
