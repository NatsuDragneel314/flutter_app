import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  final CartService cart;
  const CartScreen({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: cart,
        builder: (_, __) {
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const Text('My Cart',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5)),
                    const SizedBox(width: 8),
                    if (cart.itemCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12)),
                      ),
                    const Spacer(),
                    if (cart.items.isNotEmpty)
                      GestureDetector(
                        onTap: cart.clear,
                        child: Text('Clear all',
                            style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),

              if (cart.items.isEmpty)
                Expanded(child: _buildEmpty(context))
              else ...[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _CartItemTile(item: cart.items[i], cart: cart),
                  ),
                ),
                _buildSummary(context),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛒', style: TextStyle(fontSize: 70)),
          const SizedBox(height: 16),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text('Add items to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'Rs ${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow(
            'Shipping',
            cart.shipping == 0 ? 'FREE 🎉' : 'Rs ${cart.shipping.toStringAsFixed(2)}',
            valueColor:
                cart.shipping == 0 ? const Color(0xFF22C55E) : null,
          ),
          const Divider(height: 24),
          _summaryRow('Total', 'Rs ${cart.total.toStringAsFixed(2)}',
              isBold: true, valueColor: const Color(0xFF6C63FF)),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              cart.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order placed! 🎉 Thank you!'),
                  backgroundColor: const Color(0xFF22C55E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Proceed to Checkout',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (cart.shipping > 0)
            Text(
              'Add Rs ${(100 - cart.subtotal).toStringAsFixed(2)} more for free shipping!',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? const Color(0xFF1A1A2E) : Colors.grey[600])),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: isBold ? 20 : 14,
                fontWeight: FontWeight.w700,
                color: valueColor ??
                    (isBold ? const Color(0xFF1A1A2E) : Colors.grey[800]))),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartService cart;

  const _CartItemTile({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(item.product.emoji,
                  style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Rs ${item.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
          // Qty controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => cart.removeFromCart(item.product.id),
                child: Icon(Icons.close_rounded,
                    size: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _qtyBtn(Icons.remove,
                      () => cart.decrement(item.product.id)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('${item.quantity}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  _qtyBtn(
                      Icons.add, () => cart.increment(item.product.id)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EFFE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: const Color(0xFF6C63FF)),
      ),
    );
  }
}
