import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/discount_provider.dart';
import 'package:erp_ecommerce/widgets/search_filter_bar.dart';

class DiscountListScreen extends StatefulWidget {
  const DiscountListScreen({super.key});

  @override
  State<DiscountListScreen> createState() => _DiscountListScreenState();
}

class _DiscountListScreenState extends State<DiscountListScreen> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = false;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  DateTime? _entryDate;
  DateTime? _validFrom;
  DateTime? _validTo;

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

    // Fetch discounts when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscountProvider>().fetchDiscounts();
    });
  }

  Future<void> _selectDate(BuildContext context, int type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (type == 1) _entryDate = picked;
        if (type == 2) _validFrom = picked;
        if (type == 3) _validTo = picked;
      });
    }
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
        title: Text('Discount List',
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
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    'Save Discount',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 4,
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
                        _buildFabAction('New Discount', Icons.add, onTap: () {
                          setState(() {
                            _isFormVisible = true;
                            _isGridView = false;
                            _toggleFab();
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Discount Grid', Icons.grid_view, onTap: () {
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
                    _isFabExpanded ? Icons.close : Icons.local_offer_outlined,
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildSearchRow(),
        ),
        Expanded(
          child: Consumer<DiscountProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
              }

              if (provider.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(provider.errorMessage, 
                        style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => provider.fetchDiscounts(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text('Retry Connection', style: GoogleFonts.poppins(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              if (provider.discounts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer_outlined, color: Color(0xFF26A69A), size: 64),
                      ),
                      const SizedBox(height: 24),
                      Text('No Discounts Found', 
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                      const SizedBox(height: 8),
                      Text('No active discount campaigns at this time', 
                        style: GoogleFonts.poppins(color: Colors.grey[600])),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62, // Increased height for metadata
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: provider.discounts.length,
                itemBuilder: (context, index) {
                  final item = provider.discounts[index];
                  return _buildDiscountCard(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountCard(DiscountItem item) {
    final bool isActive = item.status.toLowerCase() == 'active';
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 90,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF0FDFA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.local_offer_outlined, size: 40, color: Color(0xFF26A69A)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFF26A69A).withOpacity(0.1),
                    child: Text(
                      item.discountType == 'Percentage' ? '${item.discountValue}% OFF' : '₹${item.discountValue} OFF',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: const Color(0xFF26A69A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName.isEmpty ? 'Untitled Promo' : item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.productCategory.isEmpty ? 'General Category' : item.productCategory,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                  ),
                  const Divider(height: 16),
                  _buildCompactRow(Icons.tag, 'Code: ${item.productCode}'),
                  _buildCompactRow(Icons.calendar_today, 'Date: ${item.date.split(' ')[0]}'),
                  _buildCompactRow(Icons.timer_outlined, 'V: ${item.validFrom.split(' ')[0]} - ${item.validTo.split(' ')[0]}'),
                  if (item.remarks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 10, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.remarks,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500], fontStyle: FontStyle.italic),
                            ),
                          ),
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

  Widget _buildCompactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 10, color: const Color(0xFF26A69A)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return SearchFilterBar(
      hintText: 'Search discounts...',
      onSearchChanged: (value) {
        // Search logic here
      },
    );
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text('Discount Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ),
        _buildDatePickerField('Date', _entryDate, () => _selectDate(context, 1)),
        _buildInputField('Product Name', 'Product Name'),
        _buildInputField('Product Category', 'Product Category'),
        _buildInputField('Discount Type', 'Discount Type'),
        _buildInputField('Discount Value', 'Discount Value'),
        _buildDatePickerField('Valid From', _validFrom, () => _selectDate(context, 2)),
        _buildDatePickerField('Valid to', _validTo, () => _selectDate(context, 3)),
        _buildInputField('Status', 'Status'),
        _buildInputField('Remarks', 'Remarks'),
        _buildInputField('Product Code', 'Product Code'),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date != null ? DateFormat('dd-MM-yyyy').format(date!) : 'Select Date',
                      style: TextStyle(color: date != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {bool isDropdown = false, int maxLines = 1, IconData? suffix}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                maxLines: maxLines,
                readOnly: isDropdown || suffix != null,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                  suffixIcon: isDropdown 
                    ? const Icon(Icons.arrow_drop_down, color: Color(0xFF94A3B8))
                    : (suffix != null ? Icon(suffix, color: const Color(0xFF94A3B8), size: 20) : null),
                ),
              ),
            ),
          ],
        ),
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
