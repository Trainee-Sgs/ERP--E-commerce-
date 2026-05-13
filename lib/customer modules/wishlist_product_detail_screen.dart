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
    final processedName = name.replaceAll(' ', '');
    final prefix = processedName.length >= 4 
        ? processedName.substring(0, 4) 
        : processedName;
    final productCode = 'ERP-${prefix.toUpperCase()}-001';
    
    final id         = widget.product['id']?.toString()         ?? '';
    final wishlistId = widget.product['wishlist_id']?.toString() ?? '';
    final customerId = widget.product['customer_id']?.toString() ?? '';
    final productId  = widget.product['product_id']?.toString()  ?? '';
    final unitSize   = widget.product['unit_size']?.toString()   ?? '';
    final quantity   = widget.product['quantity']?.toString()   ?? '';
    final addedDate  = widget.product['added_date']?.toString()  ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A), // Teal Theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () { if (Navigator.canPop(context)) { Navigator.pop(context); } },
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product image section ──────────────────────────────
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.white,
                        child: Center(
                          child: Hero(
                            tag: 'wishlist_$id',
                            child: widget.product['image'] != null && widget.product['image'].toString().isNotEmpty
                                ? Image.network(widget.product['image'], fit: BoxFit.contain)
                                : Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF26A69A).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      category.toLowerCase().contains('phone') ? Icons.phone_iphone :
                                      category.toLowerCase().contains('laptop') ? Icons.laptop :
                                      category.toLowerCase().contains('audio') ? Icons.headphones :
                                      Icons.devices,
                                      size: 100,
                                      color: const Color(0xFF26A69A),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 16,
                        top: 20,
                        child: Column(
                          children: [
                            _circularIcon(Icons.favorite, Colors.red),
                            const SizedBox(height: 16),
                            _circularIcon(Icons.share_outlined, Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Indicator
                  Center(
                    child: Container(
                      width: 30,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F51B5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),

                  // ── Details section ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: SMMPWL-001',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(color: Colors.black87),
                            children: [
                              const TextSpan(text: 'Price  ', style: TextStyle(fontSize: 16)),
                              TextSpan(
                                text: '₹$price',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ...List.generate(5, (i) => const Icon(Icons.star, color: Color(0xFFCDDC39), size: 24)),
                            const SizedBox(width: 8),
                            Text(
                              '4.3 (128 reviews)',
                              style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Status buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF4CAF50)),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFE8F5E9),
                                ),
                                child: const Center(
                                  child: Text('Tax: 5%', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFF3F51B5)),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFE8EAF6),
                                ),
                                child: const Center(
                                  child: Text('Stock: 2', style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Green Grid
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26A69A), // Teal theme
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _gridItem(Icons.alt_route, 'Code', 'SMMPWL-001'),
                              Container(height: 40, width: 1, color: Colors.white30),
                              _gridItem(Icons.money, 'Price', '₹$price'),
                              Container(height: 40, width: 1, color: Colors.white30),
                              _gridItem(Icons.battery_charging_full, 'Stock', '2 units'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Detailed Specifications Table
                        Text(
                          'Product Specifications',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            children: [
                              _buildDetailTableRow('ID', id, true),
                              _buildDetailTableRow('Wishlist ID', wishlistId, false),
                              _buildDetailTableRow('Customer ID', customerId, true),
                              _buildDetailTableRow('Product ID', productId, false),
                              _buildDetailTableRow('Product Name', name, true),
                              _buildDetailTableRow('Unit Size', unitSize, false),
                              _buildDetailTableRow('Quantity', quantity, true),
                              _buildDetailTableRow('Added Date', addedDate, false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _gridItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailTableRow(String label, String value, bool isAlt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAlt ? const Color(0xFFF8FAFC) : Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
