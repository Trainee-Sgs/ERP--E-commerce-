import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:erp_ecommerce/widgets/app_drawer.dart';
import 'package:erp_ecommerce/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:erp_ecommerce/providers/order_provider.dart';
import 'package:erp_ecommerce/widgets/search_filter_bar.dart';
import 'package:erp_ecommerce/widgets/dashboard_screen.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  String _selectedStatus = 'All';
  bool _isFormVisible = false;
  bool _isGridView = true;

  DateTime? _orderDate;
  DateTime? _cancellationDate;
  DateTime? _itemDate;

  @override
  void initState() {
    // Fetch orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
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
        if (type == 1) _orderDate = picked;
        if (type == 2) _cancellationDate = picked;
        if (type == 3) _itemDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
            }
          },
        ),
        title: Text('All Orders',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchFilterBar(
              hintText: 'Search orders...',
              onSearchChanged: (value) {},
            ),
          ),
          _buildStatusFilterRow(),
          Expanded(child: _buildGridViewContent()),
        ],
      ),
    );
  }

  Widget _buildStatusFilterRow() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final pendingCount   = provider.orders.where((o) {final s = o.status.toLowerCase(); return s == 'pending' || s == 'progress' || s == '';}).length;
        final confirmedCount = provider.orders.where((o) => o.status.toLowerCase() == 'confirmed').length;
        final shippingCount  = provider.orders.where((o) {final s = o.status.toLowerCase(); return s == 'shipping' || s == 'shipped';}).length;
        final deliveredCount = provider.orders.where((o) => o.status.toLowerCase() == 'delivered').length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildStatusChip('All', provider.orders.length, Colors.blueGrey, _selectedStatus == 'All'),
              const SizedBox(width: 12),
              _buildStatusChip('Pending', pendingCount, Colors.orange, _selectedStatus == 'Pending'),
              const SizedBox(width: 12),
              _buildStatusChip('Confirmed', confirmedCount, Colors.blue, _selectedStatus == 'Confirmed'),
              const SizedBox(width: 12),
              _buildStatusChip('Shipping', shippingCount, Colors.purple, _selectedStatus == 'Shipping'),
              const SizedBox(width: 12),
              _buildStatusChip('Delivered', deliveredCount, Colors.green, _selectedStatus == 'Delivered'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status, int count, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withOpacity(0.2) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchFilterBar(
            hintText: 'Search orders...',
            onSearchChanged: (value) {},
          ),
          const SizedBox(height: 20),
          Text(
            'Add New Order',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          
          // Section 1: Customer & Address
          _buildSectionCard('Customer Information', [
            _buildInputField('Customer ID', 'Enter Customer ID'),
            _buildInputField('Billing Address', 'Billing Address'),
            _buildInputField('Billing Address 2', 'Billing Address'),
            _buildInputField('Shipping Address', 'Shipping Address'),
          ]),
          
          // Section 2: Order Details
          _buildSectionCard('Order Details', [
            _buildInputField('Order Status', 'Order Status'),
            _buildDatePickerField('Order Date', _orderDate, () => _selectDate(context, 1)),
            _buildInputField('Shipping Method', 'Shipping Method'),
            _buildInputField('Shipping Cost', 'Shipping Cost'),
            _buildInputField('Total Price', 'Total Price'),
          ]),

          // Section 3: Cancellation & Logistics
          _buildSectionCard('Cancellation & Tracking', [
            _buildDatePickerField('Cancellation Date', _cancellationDate, () => _selectDate(context, 2)),
            _buildInputField('Cancellation Reason', 'Cancellation Reason'),
            _buildInputField('Cancelled By', 'Cancelled By'),
            _buildInputField('Tracking Number', 'Tracking Number'),
          ]),

          // Section 4: Payment Details
          _buildSectionCard('Payment Information', [
            _buildInputField('Payment Status', 'Payment Status'),
            _buildInputField('Payment Method', 'Payment Method'),
            _buildInputField('Coupon Code', 'Coupon Code'),
            _buildInputField('Refund Status', 'Refund Status'),
            _buildInputField('Account Number', 'Account Number'),
            _buildInputField('Bank Name', 'Bank Name'),
            _buildInputField('Holder Name', 'Holder Name'),
            _buildInputField('IFSC', 'IFSC'),
          ]),

          // Section 5: Line Items
          _buildSectionCard('Product Items', [
            _buildInputField('PID Count', 'PID Count'),
            _buildDatePickerField('Date', _itemDate, () => _selectDate(context, 3)),
            const Divider(height: 32),
            _buildProductRow(),
          ]),

          // ── Replaced Cancel/Save bar with Banner-style Publish button ──
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
              label: Text(
                'Save Order',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF26A69A).withOpacity(0.4),
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF26A69A))),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProductRow() {
    return Column(
      children: [
        _buildInputField('Product ID', 'Product ID'),
        _buildInputField('Discount', 'Discount'),
        _buildInputField('Tax', 'Tax'),
        _buildInputField('Price', 'Price'),
        _buildInputField('Quantity', 'Quantity'),
      ],
    );
  }


  Widget _buildGridViewContent() {
    return Column(
      children: [
        Expanded(
          child: Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              if (orderProvider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
              }

              final filteredOrders = _selectedStatus == 'All' 
                ? orderProvider.orders 
                : orderProvider.orders.where((o) {
                    final s = o.status.toLowerCase();
                    if (_selectedStatus == 'Pending') return s == 'pending' || s == 'progress' || s == '';
                    if (_selectedStatus == 'Shipping') return s == 'shipping' || s == 'shipped';
                    return s == _selectedStatus.toLowerCase();
                  }).toList();

              if (orderProvider.errorMessage.isNotEmpty) {
                return _buildErrorView(orderProvider.errorMessage, () => orderProvider.fetchOrders());
              }

              if (filteredOrders.isEmpty) {
                return _buildEmptyView();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    final statusColor = _getStatusColor(order.status);
    final status = order.status.isEmpty ? 'Pending' : order.status;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Order #${order.id}', 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B))),
                        const SizedBox(width: 8),
                        if (order.productCode.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(order.productCode, 
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(order.dtime.isNotEmpty ? order.dtime : 'No date provided', 
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          
          // Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildOrderInfo('Customer UID', order.customerId.isEmpty ? 'N/A' : order.customerId, Icons.person_outline),
                const Spacer(),
                _buildOrderInfo('Amount', '₹${order.amount.toStringAsFixed(2)}', Icons.payments_outlined, isPrimary: true),
              ],
            ),
          ),

          // Flow Actions Section (The "CRT functioning" part)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildFlowActions(order),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(String label, String value, IconData icon, {bool isPrimary = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500)),
            Text(value, 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, 
                fontSize: 13, 
                color: isPrimary ? const Color(0xFF26A69A) : const Color(0xFF1E293B)
              )
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowActions(OrderItem order) {
    final status = order.status.toLowerCase();
    
    // Define the flow: Pending -> Confirmed -> Shipped -> Delivered
    if (status == 'pending' || status == 'progress' || status == '') {
      return _buildActionButton('Confirm Order', Icons.check_circle_outline, Colors.blue, () {
        context.read<OrderProvider>().updateOrderStatus(order.id, 'Confirmed');
      });
    } else if (status == 'confirmed') {
      return _buildActionButton('Dispatch / Ship', Icons.local_shipping_outlined, Colors.purple, () {
        context.read<OrderProvider>().updateOrderStatus(order.id, 'Shipped');
      });
    } else if (status == 'shipped') {
      return _buildActionButton('Mark Delivered', Icons.task_alt, Colors.green, () {
        context.read<OrderProvider>().updateOrderStatus(order.id, 'Delivered');
      });
    } else if (status == 'delivered') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text('ORDER COMPLETED', style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: Colors.red)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry Connection')),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF26A69A).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF26A69A), size: 64),
          ),
          const SizedBox(height: 24),
          Text('No Orders Found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('No $_selectedStatus orders in this category', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }



  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildCardItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date != null ? DateFormat('dd-MM-yyyy').format(date!) : 'dd-mm-yyyy',
                    style: TextStyle(color: date != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {IconData? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                suffixIcon: suffix != null ? Icon(suffix, color: const Color(0xFF94A3B8), size: 18) : null,
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
