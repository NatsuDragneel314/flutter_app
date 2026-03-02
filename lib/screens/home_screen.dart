import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  final CartService _cart = CartService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filtered = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _isSearching = false;
  int _navIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _api.fetchProducts();
    final categories = _api.categories;
    setState(() {
      _products = products;
      _filtered = products;
      _categories = categories;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  Future<void> _filterCategory(String cat) async {
    setState(() {
      _selectedCategory = cat;
      _isLoading = true;
    });
    _fadeController.reset();
    final products = await _api.fetchByCategory(cat);
    setState(() {
      _filtered = products;
      _isLoading = false;
    });
    _fadeController.forward();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filtered = _products;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final results = await _api.search(query);
    setState(() {
      _filtered = results;
      _isSearching = false;
    });
  }

  void _toggleFav(Product p) async {
    await _api.toggleFavorite(p.id);
    setState(() {
      p.isFavorite = !p.isFavorite;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildShopTab(),
          FavoritesScreen(products: _products, onToggleFav: _toggleFav),
          CartScreen(cart: _cart),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildShopTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildTopBar(),
          _buildSearchBar(),
          _buildCategories(),
          _buildBanner(),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400),
              ),
              const Text(
                'Find your style',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined,
                    size: 22, color: Color(0xFF1A1A2E)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('JD',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _search,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search products…',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: Colors.grey[400], size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _search('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          return CategoryChip(
            label: cat,
            isSelected: _selectedCategory == cat,
            onTap: () => _filterCategory(cat),
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('LIMITED OFFER',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1)),
                        ),
                        const SizedBox(height: 6),
                        const Text('Up to 30% OFF\nElectronics! ⚡',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                height: 1.3)),
                      ],
                    ),
                  ),
                  const Text('🎧', style: TextStyle(fontSize: 52)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No products found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600])),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            return ProductCard(
              product: _filtered[i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: _filtered[i],
                      cart: _cart,
                      onToggleFav: () => _toggleFav(_filtered[i]),
                    ),
                  ),
                );
              },
              onAddToCart: () {
                _cart.addToCart(_filtered[i]);
                _showCartSnack(_filtered[i].name);
              },
              onToggleFav: () => _toggleFav(_filtered[i]),
            );
          },
        ),
      ),
    );
  }

  void _showCartSnack(String name) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added to cart 🛒'),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _logout() {
    AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const LoginScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  Widget _buildProfileTab() {
    final auth = AuthService();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                  child: Text(auth.userInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 28))),
            ),
            const SizedBox(height: 16),
            Text(auth.userName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E))),
            Text(auth.userEmail,
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 28),
            // Stats row
            Row(
              children: [
                _statCard('12', 'Orders'),
                const SizedBox(width: 12),
                _statCard('3', 'Wishlist'),
                const SizedBox(width: 12),
                _statCard('★ 4.9', 'Rating'),
              ],
            ),
            const SizedBox(height: 24),
            // Menu items
            ...[
              ('📦', 'My Orders', 'Track your deliveries', null),
              ('💳', 'Payment Methods', 'Cards & wallets', null),
              ('📍', 'Delivery Addresses', 'Manage addresses', null),
              ('🔔', 'Notifications', 'Manage alerts', null),
              ('❓', 'Help & Support', 'FAQs & contact', null),
            ].map((item) =>
                _profileMenuItem(item.$1, item.$2, item.$3, onTap: item.$4)),
            _profileMenuItem('🚪', 'Log Out', 'See you soon!',
                onTap: _logout, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6C63FF))),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(String emoji, String title, String sub,
      {VoidCallback? onTap, bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDestructive
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF1A1A2E))),
        subtitle: Text(sub,
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Icon(Icons.chevron_right_rounded,
            color: isDestructive
                ? const Color(0xFFFF6B6B).withValues(alpha: 0.5)
                : Colors.grey[400]),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ListenableBuilder(
      listenable: _cart,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4))
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (i) => setState(() => _navIndex = i),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Saved'),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    if (_cart.itemCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _cart.itemCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_rounded),
                    if (_cart.itemCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _cart.itemCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
