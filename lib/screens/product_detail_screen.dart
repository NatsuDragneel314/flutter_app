import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final CartService cart;
  final VoidCallback onToggleFav;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.cart,
    required this.onToggleFav,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  int _quantity = 1;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _addToCart() {
    for (int i = 0; i < _quantity; i++) {
      widget.cart.addToCart(widget.product);
    }
    setState(() => _added = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: CustomScrollView(
        slivers: [
          // ── App Bar with large emoji/image area ──
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Color(0xFF1A1A2E)),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  widget.onToggleFav();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(
                    p.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    size: 20,
                    color: p.isFavorite ? const Color(0xFFFF6B6B) : Colors.grey,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6C63FF).withValues(alpha: 0.08),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(p.emoji,
                        style: const TextStyle(fontSize: 110)),
                  ],
                ),
              ),
            ),
          ),

          // ── Product Details ──
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F8FC),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category + rating
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(p.category,
                                    style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ),
                              const Spacer(),
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFC107), size: 18),
                              const SizedBox(width: 4),
                              Text(p.rating.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14)),
                              Text(' (${p.reviews})',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Product name
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -0.5,
                                  height: 1.2)),
                          const SizedBox(height: 14),
                          // Price row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rs ${p.price.toStringAsFixed(2)}',  
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF6C63FF),
                                      letterSpacing: -1)),
                              const SizedBox(width: 10),
                              if (p.hasDiscount) ...[
                                Text('Rs ${p.originalPrice.toStringAsFixed(2)}',  
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[400],
                                        decoration: TextDecoration.lineThrough)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${p.discountPercent.toInt()}%',
                                    style: const TextStyle(
                                        color: Color(0xFFFF6B6B),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Description
                          const Text('Description',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 8),
                          Text(p.description,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.6)),
                          const SizedBox(height: 20),
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: p.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: Text(tag,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          // Stock
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: p.stock > 10
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFFFA500),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.stock > 10
                                    ? 'In Stock (${p.stock} available)'
                                    : 'Low Stock — only ${p.stock} left!',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: p.stock > 10
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFFFA500),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Quantity Selector
                          Row(
                            children: [
                              const Text('Quantity',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E))),
                              const Spacer(),
                              _qtyButton(
                                  Icons.remove,
                                  () => setState(() =>
                                      _quantity = (_quantity - 1).clamp(1, 99))),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: Text('$_quantity',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1A1A2E))),
                              ),
                              _qtyButton(
                                  Icons.add,
                                  () => setState(
                                      () => _quantity = (_quantity + 1).clamp(1, p.stock))),
                            ],
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                    // ── Add to Cart Button ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: GestureDetector(
                        onTap: _addToCart,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _added
                                  ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                                  : [const Color(0xFF6C63FF), const Color(0xFF3D5AF1)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: (_added
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFF6C63FF))
                                    .withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _added ? Icons.check_rounded : Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _added
                                    ? 'Added to Cart!'
                                    : 'Add to Cart  •  Rs ${(p.price * _quantity).toStringAsFixed(2)}',  
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A2E)),
      ),
    );
  }
}
