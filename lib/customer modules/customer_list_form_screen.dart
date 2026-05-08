import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CustomerListFormScreen extends StatefulWidget {
  const CustomerListFormScreen({super.key});

  @override
  State<CustomerListFormScreen> createState() => _CustomerListFormScreenState();
}

class _CustomerListFormScreenState extends State<CustomerListFormScreen> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = true;
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  DateTime? _installDate;
  DateTime? _renewalDate;

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

  Future<void> _selectDate(BuildContext context, bool isInstallDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isInstallDate) {
          _installDate = picked;
        } else {
          _renewalDate = picked;
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Customer List Form',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        
      ),
      body: Stack(
        children: [
          // Content
          _isFormVisible ? _buildFormContent() : _buildGridViewContent(),

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
                        _buildFabAction('New Entry', Icons.person_add_outlined, onTap: () {
                          setState(() {
                            _isFormVisible = true;
                            _isGridView = false;
                            _toggleFab();
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('List View', Icons.view_list_outlined, onTap: () {
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
                    _isFabExpanded ? Icons.close : Icons.people_alt_outlined,
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
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            label: Text(
              'Save Customer',
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
          const SizedBox(height: 100),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 12,
            itemBuilder: (context, index) {
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
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text('C${index + 1}', style: const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer CID: CID-900${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Software: Enterprise ERP v2.0', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Color(0xFF2563EB)),
                hintText: 'Search software customers...',
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: const Icon(Icons.tune, color: Color(0xFF64748B)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Management', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 24),
          _buildInputField('Customer CID', 'Customer CID'),
          _buildInputField('Customer Name', 'Customer Name'),
          _buildInputField('Customer Type', 'Select Option', suffix: Icons.arrow_drop_down),
          _buildInputField('Mobile', 'Mobile'),
          _buildInputField('Whatsapp', 'Whatsapp'),
          _buildInputField('Email ID', 'Email ID'),
          _buildInputField('Address', 'Address'),
          _buildInputField('City', 'Namakkal', suffix: Icons.arrow_drop_down),
          _buildInputField('State', 'State'),
          _buildInputField('Country', 'Country'),
          _buildInputField('Pincode', 'Pincode'),
          _buildInputField('GST', 'GST'),
          _buildInputField('Status', 'Status'),
          _buildInputField('Software Type', 'Software Type'),
          _buildInputField('Software Name', 'Software Name'),
          _buildInputField('Software Version', 'Software Version'),
          
          _buildDatePickerField('Install Date', _installDate, () => _selectDate(context, true)),
          _buildDatePickerField('Renewal Date', _renewalDate, () => _selectDate(context, false)),
          
          _buildInputField('Renewal Amount', 'Renewal Amount'),
          _buildInputField('Remarks', 'Remarks', isMultiline: true),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {IconData? suffix, bool isMultiline = false}) {
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
              maxLines: isMultiline ? 4 : 1,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                suffixIcon: suffix != null ? Icon(suffix, color: const Color(0xFF94A3B8), size: 18) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
