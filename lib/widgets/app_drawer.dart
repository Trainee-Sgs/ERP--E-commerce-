import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../product modules/product_list_screen.dart';
import '../product modules/ecom_product_screen.dart';
import '../price modules/price_list_screen.dart';
import '../price modules/discount_list_screen.dart';
import '../access module/banner_image_screen.dart';
import '../access module/all_orders_screen.dart';
import '../customer modules/customer_details_screen.dart';
import '../customer modules/address_book_screen.dart';
import '../customer modules/customer_orders_screen.dart';
import '../customer modules/wishlist_screen.dart';
import '../customer modules/cart_abandonment_screen.dart';
import '../customer modules/customer_list_form_screen.dart';
import '../access module/document_upload_screen.dart';
import '../access module/category_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          const SizedBox(height: 10),
          
          // Product Modules
          if (_isVisible(context, 'Ecom Product List'))
            _buildDrawerItem(
              icon: Icons.inventory_2_outlined,
              title: 'Ecom Product List',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
              },
            ),
            
          if (_isVisible(context, 'E com Product'))
            _buildDrawerItem(
              icon: Icons.shopping_bag_outlined,
              title: 'E com Product',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EcomProductScreen()));
              },
            ),
            
          if (_isVisible(context, 'Category'))
            _buildDrawerItem(
              icon: Icons.category_outlined,
              title: 'Category',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()));
              },
            ),

          // Price Module
          if (_isVisible(context, 'Ecom Price'))
            _buildExpansionTile(
              icon: Icons.local_offer_outlined,
              title: 'Ecom Price',
              children: [
                if (_isVisible(context, 'Price list'))
                  _buildSubItem(
                    icon: Icons.radio_button_off,
                    title: 'Price list', 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PriceListScreen()));
                    }
                  ),
                if (_isVisible(context, 'Discount list'))
                  _buildSubItem(
                    icon: Icons.radio_button_off,
                    title: 'Discount list', 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscountListScreen()));
                    }
                  ),
              ],
            ),

          if (_isVisible(context, 'Banner Image'))
            _buildDrawerItem(
              icon: Icons.crop_original_outlined,
              title: 'Banner Image',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BannerImageScreen()));
              },
            ),

          // Orders Module
          if (_isVisible(context, 'Orders'))
            _buildExpansionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Orders',
              children: [
                if (_isVisible(context, 'All Orders'))
                  _buildSubItem(
                    icon: Icons.radio_button_off,
                    title: 'All Orders', 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllOrdersScreen()));
                    }
                  ),
              ],
            ),

          // Customers Module
          if (_isVisible(context, 'Customers'))
            _buildExpansionTile(
              icon: Icons.group_outlined,
              title: 'Customers',
              children: [
                if (_isVisible(context, 'Customer details'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Customer details', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerDetailsScreen()));
                  }),
                if (_isVisible(context, 'Address Book'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Address Book', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressBookScreen()));
                  }),
                if (_isVisible(context, 'Customer Orders'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Customer Orders', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerOrdersScreen()));
                  }),
                if (_isVisible(context, 'Ecom Wishlist'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Ecom Wishlist', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
                  }),
                if (_isVisible(context, 'Cart Abandonment'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Cart Abandonment', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartAbandonmentScreen()));
                  }),
                if (_isVisible(context, 'Customer List'))
                  _buildSubItem(icon: Icons.radio_button_off, title: 'Customer List', onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListFormScreen()));
                  }),
              ],
            ),

          if (_isVisible(context, 'Document Uploads'))
            _buildDrawerItem(
              icon: Icons.cloud_upload_outlined,
              title: 'Document Uploads',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentUploadScreen()));
              },
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Helper to check visibility from the global MenuProvider
  bool _isVisible(BuildContext context, String title) {
    try {
      // Use dynamic to avoid circular dependency with the main app's MenuProvider
      final menuProvider = Provider.of<dynamic>(context, listen: false);
      return menuProvider.isSubMenuVisible("E-COMMERCE", title);
    } catch (e) {
      // Default to visible if provider not found
      return true;
    }
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF00A79A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'E-commerce',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00A79A), size: 22),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E293B),
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF00A79A), size: 22),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF00A79A)),
        children: children,
        tilePadding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
  }

  Widget _buildSubItem({required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: const SizedBox(width: 24),
      title: Row(
        children: [
          Icon(icon, color: const Color(0xFF00A79A), size: 20),
          const SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
      onTap: onTap ?? () {},
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
