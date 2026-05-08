import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav_bar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = false;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // ── dummy data matching form fields ──
  final List<Map<String, String>> _products = List.generate(6, (i) => {
    'productId':       'PRD-${1001 + i}',
    'productName':     'Product ${i + 1}',
    'category':        'Category ${(i % 3) + 1}',
    'brand':           (i % 2) == 0 ? 'Brand Alpha' : 'Brand Beta',
    'description':     'High quality product with premium features and long-lasting durability.',
    'basePrice':       '\$${(i + 1) * 50}.00',
    'manufactureInfo': 'Mfg. Jan 202${i % 5 + 1}',
    'offerPrice':      '\$${(i + 1) * 40}.00',
    'gstTax':          '${(i % 3 + 1) * 5}%',
  });

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product List',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          _isFormVisible
              ? _buildProductForm()
              : (_isGridView ? _buildProductListView() : _buildEmptyState()),

          if (_isFabExpanded)
            GestureDetector(
              onTap: _toggleFab,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),

          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ScaleTransition(
                  scale: _expandAnimation,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildFabAction('New Product', Icons.add_shopping_cart,
                            onTap: () {
                          setState(() {
                            _isFormVisible = true;
                            _isGridView = false;
                          });
                          _toggleFab();
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Product Grid', Icons.grid_view_rounded,
                            onTap: () {
                          setState(() {
                            _isFormVisible = false;
                            _isGridView = true;
                          });
                          _toggleFab();
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: _toggleFab,
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(
                    _isFabExpanded
                        ? Icons.close
                        : Icons.inventory_2_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  PRODUCT LIST VIEW  — cards with all form fields
  // ─────────────────────────────────────────────
  Widget _buildProductListView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchRow(),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final p = _products[index];
              return _buildProductCard(p);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, String> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── icon placeholder ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFF26A69A).withOpacity(0.08),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 34,
                    color: Color(0xFF26A69A),
                  ),
                ),
              ),
            ),
          ),

          // ── product name + ID ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p['productName']!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p['productId']!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF26A69A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20),
          ),

          // ── info rows ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Column(
              children: [
                _buildInfoRow(Icons.category_outlined,
                    'Category', p['category']!),
                _buildInfoRow(Icons.branding_watermark_outlined,
                    'Brand', p['brand']!),
                _buildInfoRow(Icons.description_outlined,
                    'Description', p['description']!),
                _buildInfoRow(Icons.factory_outlined,
                    'Manufacture Info', p['manufactureInfo']!),
              ],
            ),
          ),

          // ── price chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildPriceChip(
                      'Base Price', p['basePrice']!,
                      const Color(0xFF64748B)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPriceChip(
                      'Offer Price', p['offerPrice']!,
                      const Color(0xFF26A69A)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPriceChip(
                      'GST / Tax', p['gstTax']!,
                      const Color(0xFFF59E0B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FORM
  // ─────────────────────────────────────────────
  Widget _buildProductForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchRow(),
          const SizedBox(height: 24),
          _buildFormCard(),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isFormVisible = false),
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              'Save Product',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A),
              padding: const EdgeInsets.symmetric(
                  horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              elevation: 8,
              shadowColor: const Color(0xFF26A69A).withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('No products found',
              style: GoogleFonts.poppins(
                  color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                setState(() => _isFormVisible = true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A)),
            child: const Text('Add Your First Product',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10)
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Color(0xFF2563EB)),
                hintText: 'Search products...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          child:
              const Icon(Icons.tune, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product Matrix',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B))),
          const SizedBox(height: 24),
          _buildInputField('Product ID', 'Product ID'),
          _buildInputField('Product Name', 'Product Name'),
          _buildInputField('Category', 'Select Category',
              isDropdown: true),
          _buildInputField('Brand', 'Brand Name'),
          _buildInputField('Description', 'Product Description',
              maxLines: 3),
          _buildInputField('Base Price', 'Base Price'),
          _buildInputField('Manufacture Info', 'Manufacture Info'),
          _buildInputField('Offer Price', 'Offer Price'),
          _buildInputField('GST/Tax', 'GST/Tax'),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint,
      {bool isDropdown = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              maxLines: maxLines,
              readOnly: isDropdown,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: InputBorder.none,
                suffixIcon: isDropdown
                    ? const Icon(Icons.arrow_drop_down,
                        color: Color(0xFF94A3B8))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF26A69A), size: 24),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26A69A))),
          ],
        ),
      ),
    );
  }
}