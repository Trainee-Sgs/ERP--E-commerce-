import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav_bar.dart';

// ══════════════════════════════════════════════════════════════
//  All Orders Screen
// ══════════════════════════════════════════════════════════════
class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  // ── Form controllers ─────────────────────────────────────────────────────
  final _customerIdCtrl       = TextEditingController();
  final _billingCtrl          = TextEditingController();
  final _billing2Ctrl         = TextEditingController();
  final _shippingCtrl         = TextEditingController();
  final _orderStatusCtrl      = TextEditingController();
  final _shippingMethodCtrl   = TextEditingController();
  final _shippingCostCtrl     = TextEditingController();
  final _totalPriceCtrl       = TextEditingController();
  final _cancelReasonCtrl     = TextEditingController();
  final _cancelledByCtrl      = TextEditingController();
  final _trackingCtrl         = TextEditingController();
  final _paymentStatusCtrl    = TextEditingController();
  final _paymentMethodCtrl    = TextEditingController();
  final _couponCtrl           = TextEditingController();
  final _refundStatusCtrl     = TextEditingController();
  final _accountNoCtrl        = TextEditingController();
  final _bankNameCtrl         = TextEditingController();
  final _holderNameCtrl       = TextEditingController();
  final _ifscCtrl             = TextEditingController();
  final _pidCountCtrl         = TextEditingController();
  final _productIdCtrl        = TextEditingController();
  final _discountCtrl         = TextEditingController();
  final _taxCtrl              = TextEditingController();
  final _priceCtrl            = TextEditingController();
  final _quantityCtrl         = TextEditingController();

  DateTime? _orderDate;
  DateTime? _cancellationDate;
  DateTime? _itemDate;

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
    // Fetch orders on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerIdCtrl.dispose();
    _billingCtrl.dispose();
    _billing2Ctrl.dispose();
    _shippingCtrl.dispose();
    _orderStatusCtrl.dispose();
    _shippingMethodCtrl.dispose();
    _shippingCostCtrl.dispose();
    _totalPriceCtrl.dispose();
    _cancelReasonCtrl.dispose();
    _cancelledByCtrl.dispose();
    _trackingCtrl.dispose();
    _paymentStatusCtrl.dispose();
    _paymentMethodCtrl.dispose();
    _couponCtrl.dispose();
    _refundStatusCtrl.dispose();
    _accountNoCtrl.dispose();
    _bankNameCtrl.dispose();
    _holderNameCtrl.dispose();
    _ifscCtrl.dispose();
    _pidCountCtrl.dispose();
    _productIdCtrl.dispose();
    _discountCtrl.dispose();
    _taxCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
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

  void _clearForm() {
    _customerIdCtrl.clear();
    _billingCtrl.clear();
    _billing2Ctrl.clear();
    _shippingCtrl.clear();
    _orderStatusCtrl.clear();
    _shippingMethodCtrl.clear();
    _shippingCostCtrl.clear();
    _totalPriceCtrl.clear();
    _cancelReasonCtrl.clear();
    _cancelledByCtrl.clear();
    _trackingCtrl.clear();
    _paymentStatusCtrl.clear();
    _paymentMethodCtrl.clear();
    _couponCtrl.clear();
    _refundStatusCtrl.clear();
    _accountNoCtrl.clear();
    _bankNameCtrl.clear();
    _holderNameCtrl.clear();
    _ifscCtrl.clear();
    _pidCountCtrl.clear();
    _productIdCtrl.clear();
    _discountCtrl.clear();
    _taxCtrl.clear();
    _priceCtrl.clear();
    _quantityCtrl.clear();
    setState(() {
      _orderDate = null;
      _cancellationDate = null;
      _itemDate = null;
    });
  }

  // ── Save order via provider ───────────────────────────────────────────────
  Future<void> _saveOrder() async {
    final order = OrderModel(
      customerId       : _customerIdCtrl.text.trim(),
      billingAddress   : _billingCtrl.text.trim(),
      billingAddress2  : _billing2Ctrl.text.trim(),
      shippingAddress  : _shippingCtrl.text.trim(),
      orderStatus      : _orderStatusCtrl.text.trim(),
      orderDate        : _orderDate != null
          ? DateFormat('dd-MM-yyyy').format(_orderDate!)
          : '',
      shippingMethod   : _shippingMethodCtrl.text.trim(),
      shippingCost     : _shippingCostCtrl.text.trim(),
      totalPrice       : _totalPriceCtrl.text.trim(),
      cancellationDate : _cancellationDate != null
          ? DateFormat('dd-MM-yyyy').format(_cancellationDate!)
          : '',
      cancellationReason: _cancelReasonCtrl.text.trim(),
      cancelledBy      : _cancelledByCtrl.text.trim(),
      trackingNumber   : _trackingCtrl.text.trim(),
      paymentStatus    : _paymentStatusCtrl.text.trim(),
      paymentMethod    : _paymentMethodCtrl.text.trim(),
      couponCode       : _couponCtrl.text.trim(),
      refundStatus     : _refundStatusCtrl.text.trim(),
      accountNumber    : _accountNoCtrl.text.trim(),
      bankName         : _bankNameCtrl.text.trim(),
      holderName       : _holderNameCtrl.text.trim(),
      ifsc             : _ifscCtrl.text.trim(),
      pidCount         : _pidCountCtrl.text.trim(),
      itemDate         : _itemDate != null
          ? DateFormat('dd-MM-yyyy').format(_itemDate!)
          : '',
      productId        : _productIdCtrl.text.trim(),
      discount         : _discountCtrl.text.trim(),
      tax              : _taxCtrl.text.trim(),
      price            : _priceCtrl.text.trim(),
      quantity         : _quantityCtrl.text.trim(),
    );

    final success = await context.read<OrderProvider>().insertOrder(order);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order saved successfully!'),
          backgroundColor: Color(0xFF26A69A),
        ),
      );
      _clearForm();
      setState(() => _isFormVisible = false);
    } else {
      final err = context.read<OrderProvider>().errorMsg;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $err'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Orders',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<OrderProvider>().fetchOrders(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isFormVisible ? _buildFormContent() : _buildOrderListContent(),

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
                        _buildFabAction('New Order', Icons.add_shopping_cart,
                            onTap: () {
                          setState(() => _isFormVisible = true);
                          _toggleFab();
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Order List', Icons.list_alt,
                            onTap: () {
                          setState(() => _isFormVisible = false);
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
                        : Icons.receipt_long_outlined,
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

  // ══════════════════════════════════════════════
  //  ORDER LIST CONTENT  (3 status cards)
  // ══════════════════════════════════════════════
  Widget _buildOrderListContent() {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF26A69A)),
          );
        }
        if (provider.errorMsg.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(provider.errorMsg,
                    style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => provider.fetchOrders(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A)),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchRow(),
              const SizedBox(height: 20),
              Text(
                'Order Overview',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                label: 'Confirmed Orders',
                count: provider.confirmedOrders.length,
                orders: provider.confirmedOrders,
                color: const Color(0xFF3B82F6),
                lightColor: const Color(0xFFEFF6FF),
                icon: Icons.check_circle_outline,
                status: 'Confirmed',
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                label: 'Shipped Orders',
                count: provider.shippedOrders.length,
                orders: provider.shippedOrders,
                color: const Color(0xFF8B5CF6),
                lightColor: const Color(0xFFF5F3FF),
                icon: Icons.local_shipping_outlined,
                status: 'Shipped',
              ),
              const SizedBox(height: 16),
              _buildStatusCard(
                label: 'Delivered Orders',
                count: provider.deliveredOrders.length,
                orders: provider.deliveredOrders,
                color: const Color(0xFF10B981),
                lightColor: const Color(0xFFECFDF5),
                icon: Icons.verified_outlined,
                status: 'Delivered',
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String label,
    required int count,
    required List<OrderModel> orders,
    required Color color,
    required Color lightColor,
    required IconData icon,
    required String status,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrdersByStatusScreen(
              status: status,
              orders: orders,
              color: color,
              icon: icon,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: lightColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('$count Orders',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: const Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(20)),
              child: Text('$count',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF94A3B8), size: 16),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  //  FORM CONTENT
  // ══════════════════════════════════════════════
  Widget _buildFormContent() {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchRow(),
              const SizedBox(height: 20),
              Text('Add New Order',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B))),
              const SizedBox(height: 16),

              // ── Customer Information ──
              _buildSectionCard('Customer Information', [
                _buildInputField('Customer ID',      'Enter Customer ID',   _customerIdCtrl),
                _buildInputField('Billing Address',  'Billing Address',     _billingCtrl),
                _buildInputField('Billing Address 2','Billing Address',     _billing2Ctrl),
                _buildInputField('Shipping Address', 'Shipping Address',    _shippingCtrl),
              ]),

              // ── Order Details ──
              _buildSectionCard('Order Details', [
                _buildInputField('Order Status',    'Order Status',    _orderStatusCtrl),
                _buildDatePickerField('Order Date', _orderDate, () => _selectDate(context, 1)),
                _buildInputField('Shipping Method', 'Shipping Method', _shippingMethodCtrl),
                _buildInputField('Shipping Cost',   'Shipping Cost',   _shippingCostCtrl),
                _buildInputField('Total Price',     'Total Price',     _totalPriceCtrl),
              ]),

              // ── Cancellation & Tracking ──
              _buildSectionCard('Cancellation & Tracking', [
                _buildDatePickerField('Cancellation Date', _cancellationDate,
                    () => _selectDate(context, 2)),
                _buildInputField('Cancellation Reason', 'Cancellation Reason', _cancelReasonCtrl),
                _buildInputField('Cancelled By',        'Cancelled By',        _cancelledByCtrl),
                _buildInputField('Tracking Number',     'Tracking Number',     _trackingCtrl),
              ]),

              // ── Payment Information ──
              _buildSectionCard('Payment Information', [
                _buildInputField('Payment Status', 'Payment Status', _paymentStatusCtrl),
                _buildInputField('Payment Method', 'Payment Method', _paymentMethodCtrl),
                _buildInputField('Coupon Code',    'Coupon Code',    _couponCtrl),
                _buildInputField('Refund Status',  'Refund Status',  _refundStatusCtrl),
                _buildInputField('Account Number', 'Account Number', _accountNoCtrl),
                _buildInputField('Bank Name',      'Bank Name',      _bankNameCtrl),
                _buildInputField('Holder Name',    'Holder Name',    _holderNameCtrl),
                _buildInputField('IFSC',           'IFSC',           _ifscCtrl),
              ]),

              // ── Product Items ──
              _buildSectionCard('Product Items', [
                _buildInputField('PID Count', 'PID Count', _pidCountCtrl),
                _buildDatePickerField('Date', _itemDate, () => _selectDate(context, 3)),
                const Divider(height: 32),
                _buildInputField('Product ID', 'Product ID', _productIdCtrl),
                _buildInputField('Discount',   'Discount',   _discountCtrl),
                _buildInputField('Tax',        'Tax',        _taxCtrl),
                _buildInputField('Price',      'Price',      _priceCtrl),
                _buildInputField('Quantity',   'Quantity',   _quantityCtrl),
              ]),

              const SizedBox(height: 32),
              Center(
                child: provider.isSaving
                    ? const CircularProgressIndicator(color: Color(0xFF26A69A))
                    : ElevatedButton.icon(
                        onPressed: _saveOrder,
                        icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                        label: Text('Save Order',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF26A69A),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF26A69A).withOpacity(0.4),
                        ),
                      ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF26A69A))),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

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
                    color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Color(0xFF2563EB)),
                hintText: 'Search orders...',
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
                  color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: const Icon(Icons.tune, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(
      String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569))),
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
                    date != null
                        ? DateFormat('dd-MM-yyyy').format(date)
                        : 'dd-mm-yyyy',
                    style: TextStyle(
                        color: date != null
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF94A3B8),
                        fontSize: 12),
                  ),
                  const Icon(Icons.calendar_today_outlined,
                      color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569))),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

// ═════════════════════════════════════════════════════════════════
//  Orders By Status Screen
// ═════════════════════════════════════════════════════════════════
class OrdersByStatusScreen extends StatefulWidget {
  final String status;
  final List<OrderModel> orders;
  final Color color;
  final IconData icon;

  const OrdersByStatusScreen({
    super.key,
    required this.status,
    required this.orders,
    required this.color,
    required this.icon,
  });

  @override
  State<OrdersByStatusScreen> createState() => _OrdersByStatusScreenState();
}

class _OrdersByStatusScreenState extends State<OrdersByStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  String _searchQuery = '';

  List<OrderModel> get _filtered => widget.orders
      .where((o) =>
          o.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.customerName.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.status} Orders',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_filtered.length} Orders',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // header strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.08),
                  border: Border(
                      bottom: BorderSide(
                          color: widget.color.withOpacity(0.2), width: 1)),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.status} Orders  •  ${_filtered.length} records',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: widget.color),
                    ),
                  ],
                ),
              ),

              // search
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Color(0xFF2563EB)),
                      hintText: 'Search orders...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // list
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(widget.icon,
                                size: 64,
                                color: widget.color.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('No ${widget.status} orders yet',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: const Color(0xFF94A3B8))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) =>
                            _buildOrderCard(_filtered[index]),
                      ),
              ),
            ],
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
                        _buildFabAction('New Order', Icons.add_shopping_cart,
                            onTap: () {
                          _toggleFab();
                          Navigator.pop(context, 'new_order');
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Order List', Icons.list_alt,
                            onTap: () {
                          _toggleFab();
                          Navigator.pop(context);
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
                    _isFabExpanded ? Icons.close : Icons.receipt_long_outlined,
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

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: widget.color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId.isNotEmpty ? '#${order.orderId}' : 'N/A',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF1E293B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: widget.color, size: 12),
                    const SizedBox(width: 4),
                    Text(order.orderStatus,
                        style: GoogleFonts.poppins(
                            color: widget.color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    order.customerName.isNotEmpty ? order.customerName : order.customerId,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF1E293B)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    order.totalPrice.isNotEmpty ? '₹${order.totalPrice}' : '—',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: widget.color),
                  ),
                ],
              ),
            ],
          ),
          if (order.trackingNumber.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text('Tracking: ${order.trackingNumber}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFabAction(String label, IconData icon,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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