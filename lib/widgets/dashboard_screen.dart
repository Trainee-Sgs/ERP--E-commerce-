import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erp_ecommerce/widgets/app_drawer.dart';
import 'package:erp_ecommerce/widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../access module/all_orders_screen.dart';
import '../product modules/product_list_screen.dart';
import '../customer modules/customer_list_form_screen.dart';
import '../price modules/discount_list_screen.dart';
import '../product modules/ecom_product_screen.dart';
import '../customer modules/address_book_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Ecommerce',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  title: 'Today Sales',
                  value: '₹24,850',
                  change: '+18.5%',
                  icon: Icons.auto_graph,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'Total Orders',
                  value: '156',
                  change: '+8.3%',
                  icon: Icons.description_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF3F51B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'Conversion Rate',
                  value: '4.8%',
                  change: '+5.3%',
                  icon: Icons.timer_outlined,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                _buildStatCard(
                  title: 'New Customers',
                  value: '89',
                  change: '+3.1%',
                  icon: Icons.person_outline,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E63), Color(0xFFD81B60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Section
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_isVisible(context, 'Orders'))
                        _buildQuickAction('Orders\nMgmt', Icons.shopping_bag, Colors.redAccent, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AllOrdersScreen()));
                        }),
                      if (_isVisible(context, 'Ecom Product List'))
                        _buildQuickAction('Product\nCatelog', Icons.inventory_2, Colors.teal, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
                        }),
                      if (_isVisible(context, 'Customers'))
                        _buildQuickAction('Customer\nMgmt', Icons.groups, Colors.deepPurple, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerListFormScreen()));
                        }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_isVisible(context, 'Discount list'))
                        _buildQuickAction('Marketing\n& Promos', Icons.trending_up, Colors.green, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DiscountListScreen()));
                        }),
                      if (_isVisible(context, 'E com Product'))
                        _buildQuickAction('Inventory\nMgmt', Icons.assignment, Colors.pink, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EcomProductScreen()));
                        }),
                      if (_isVisible(context, 'Address Book'))
                        _buildQuickAction('Shipping\n& Delivery', Icons.local_shipping, Colors.orange, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressBookScreen()));
                        }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // EMI Collections Chart
            _buildChartCard(
              title: 'EMI Collections (₹L)',
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY'];
                                if (value.toInt() < months.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[value.toInt()],
                                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          _buildBarGroup(0, 20, const Color(0xFF673AB7), '+10.3'),
                          _buildBarGroup(1, 25, const Color(0xFF1A237E), '+12.0'),
                          _buildBarGroup(2, 40, const Color(0xFF03A9F4), '+22.6'),
                          _buildBarGroup(3, 50, const Color(0xFF00BFA5), '+41.9'),
                          _buildBarGroup(4, 80, const Color(0xFFE91E63), '+83.0'),
                        ],
                      ),
                    ),
                    LineChart(
                      LineChartData(
                        minX: -0.5,
                        maxX: 4.5,
                        minY: 0,
                        maxY: 100,
                        lineTouchData: LineTouchData(enabled: false),
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 30),
                              const FlSpot(1, 35),
                              const FlSpot(2, 45),
                              const FlSpot(3, 65),
                              const FlSpot(4, 90),
                            ],
                            isCurved: false,
                            color: Colors.black54,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 4,
                                color: _getPointColor(index),
                                strokeWidth: 2,
                                strokeColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Traffic Sources Chart
            _buildChartCard(
              title: 'Traffic Sources',
              headerAction: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB2EBF2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('MONTH', style: TextStyle(fontSize: 10, color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF00796B)),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(color: Colors.redAccent, value: 30, title: '50%', radius: 40, showTitle: true, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.blueAccent, value: 15, title: '20%', radius: 40, showTitle: true, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.deepPurpleAccent, value: 15, title: '20%', radius: 40, showTitle: true, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.tealAccent, value: 20, title: '40%', radius: 40, showTitle: true, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                PieChartSectionData(color: Colors.pinkAccent, value: 20, title: '20%', radius: 40, showTitle: true, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹24.8k', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegend(Colors.tealAccent, 'Organic'),
                        _buildLegend(Colors.blueAccent, 'Social'),
                        _buildLegend(Colors.redAccent, 'Direct'),
                        _buildLegend(Colors.deepPurpleAccent, 'Paid Ads'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  change,
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child, Widget? headerAction}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 25,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getPointColor(int index) {
    const colors = [
      Color(0xFF673AB7),
      Color(0xFF1A237E),
      Color(0xFF03A9F4),
      Color(0xFF00BFA5),
      Color(0xFFE91E63),
    ];
    return colors[index % colors.length];
  }
}
