import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import 'package:erp_ecommerce/widgets/search_filter_bar.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = false;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

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

    // Fetch addresses when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () { if (Navigator.canPop(context)) { Navigator.pop(context); } },
        ),
        title: Text('Address Book',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        
      ),
      body: Stack(
        children: [
          // Content selection
          _isFormVisible ? _buildFormContent() : _buildGridViewContent(),

          // Bottom Save Button
          if (_isFormVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 4,
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

          if (_isFabExpanded)
            GestureDetector(
              onTap: _toggleFab,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          
          Positioned(
            right: 16,
            bottom: 100,
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
                        _buildFabAction('New Address', Icons.add_location_alt_outlined, onTap: () {
                          setState(() {
                            _isFormVisible = true;
                            _isGridView = false;
                            _toggleFab();
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Address Grid', Icons.grid_view_outlined, onTap: () {
                          setState(() {
                            _isFormVisible = false;
                            _isGridView = true;
                            _toggleFab();
                          });
                        }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: _toggleFab,
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Icon(
                    _isFabExpanded ? Icons.close : Icons.location_on_outlined,
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

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchRow(),
          const SizedBox(height: 24),
          _buildFormCard(),
        ],
      ),
    );
  }

  Widget _buildGridViewContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildSearchRow(),
        ),
        Expanded(
          child: Consumer<AddressProvider>(
            builder: (context, addressProvider, child) {
              if (addressProvider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
              }

              if (addressProvider.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(addressProvider.errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => addressProvider.fetchAddresses(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (addressProvider.addresses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      Text('No addresses found', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: addressProvider.addresses.length,
                itemBuilder: (context, index) {
                  final address = addressProvider.addresses[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: address.isDefault ? const Color(0xFF26A69A).withOpacity(0.1) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            address.type.toLowerCase() == 'home' ? Icons.home_outlined : Icons.work_outline,
                            color: const Color(0xFF26A69A),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${address.name} - ${address.type}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                      child: Text('DEFAULT', style: TextStyle(color: Colors.green.shade700, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                '${address.addressLine1}, ${address.addressLine2.isNotEmpty ? '${address.addressLine2}, ' : ''}${address.city}, ${address.state} - ${address.pincode}',
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, color: Colors.grey),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return SearchFilterBar(
      hintText: 'Search addresses...',
      onSearchChanged: (value) {
        // Search logic here
      },
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 24),
          _buildInputField('Customer Id', 'Customer Id'),
          _buildInputField('Name', 'Enter recipient name'),
          _buildInputField('Mobile Number', 'Mobile Number'),
          _buildInputField('Address Line 1', 'Address Line 1'),
          _buildInputField('Address Line 2', 'Address Line 2'),
          _buildInputField('Landmark', 'Landmark'),
          _buildInputField('City', 'City'),
          _buildInputField('State', 'State'),
          _buildInputField('Pincode', 'Pincode'),
          _buildInputField('Country', 'Country'),
          _buildInputField('Address type', 'e.g. Home, Office'),
          _buildInputField('Default address', 'Set as default address'),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF26A69A), size: 24),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF26A69A))),
          ],
        ),
      ),
    );
  }
}
