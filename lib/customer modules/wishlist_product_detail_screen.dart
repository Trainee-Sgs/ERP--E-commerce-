import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const WishlistProductDetailScreen({super.key, required this.product});

  @override
  State<WishlistProductDetailScreen> createState() =>
      _WishlistProductDetailScreenState();
}

class _WishlistProductDetailScreenState
    extends State<WishlistProductDetailScreen> {
  int _quantity = 1;
  bool _isWishlisted = true;
  int _selectedDot = 1; // simulate carousel

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.product['color'] as Color;
    final name = widget.product['name'] as String;
    final category = widget.product['category'] as String;
    final price = widget.product['price'] as String;
    final rating = widget.product['rating'] as double;
    final icon = widget.product['icon'] as IconData;
    // Derive a fake product code from the name
    final productCode =
        'ERP-${name.replaceAll(' ', '').substring(0, 4).toUpperCase()}-001';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          name.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
              ),
              if (_isWishlisted)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: const Text('3',
                        style: TextStyle(color: Colors.white, fontSize: 9)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product image hero ────────────────────────────────
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 280,
                        color: const Color(0xFFF1F5F9),
                        child: Center(
                          child: Icon(icon, size: 140, color: color),
                        ),
                      ),
                      // Wishlist heart on image
                      Positioned(
                        right: 16,
                        top: 16,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _isWishlisted = !_isWishlisted),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8)
                              ],
                            ),
                            child: Icon(
                              _isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isWishlisted ? Colors.red : Colors.grey,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ── Dot indicators (carousel simulation) ─────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _selectedDot;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDot = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active ? color : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Product details ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          name.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Product code
                        Text(
                          'Product Code: $productCode',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF26A69A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Category label
                        Text(
                          category.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rating row
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < rating.floor()
                                    ? Icons.star_rounded
                                    : (i < rating
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded),
                                color: const Color(0xFFF59E0B),
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 6),
                            Text(
                              '$rating / 5.0',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Color swatch (placeholder)
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.black26, width: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.black12, width: 0.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.black12, width: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Quantity row
                        Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 16),
                            // Minus
                            _quantityButton(
                                icon: Icons.remove,
                                onTap: _decrement,
                                color: const Color(0xFF26A69A)),
                            const SizedBox(width: 12),
                            Text(
                              '$_quantity',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(width: 12),
                            // Plus
                            _quantityButton(
                                icon: Icons.add,
                                onTap: _increment,
                                color: const Color(0xFF26A69A)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Price info
                        const Divider(color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 8),
                        _priceRow('M.R.P.', price),
                        const SizedBox(height: 6),
                        _priceRow('Unit', 'Piece'),
                        const SizedBox(height: 6),
                        _priceRow('Price for', price),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom action buttons ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                // Put in Cart
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                          color: Color(0xFF26A69A), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      'Put in Cart',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: const Color(0xFF26A69A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Buy Now
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF26A69A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                    ),
                    child: Text(
                      'Buy Now',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon,
      required VoidCallback onTap,
      required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
