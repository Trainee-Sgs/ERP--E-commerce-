import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import 'package:erp_ecommerce/widgets/search_filter_bar.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = false;
  bool _isGridView = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  DateTime? _createdAt;
  DateTime? _updatedAt;
  String? _profileImageName;
  final ImagePicker _picker = ImagePicker();

  // Controllers for form fields
  final TextEditingController _idController        = TextEditingController();
  final TextEditingController _custIdController    = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _mobileController    = TextEditingController();
  final TextEditingController _altMobileController = TextEditingController();
  final TextEditingController _genderController    = TextEditingController();
  final TextEditingController _regTypeController   = TextEditingController();
  final TextEditingController _statusController    = TextEditingController();

  void _loadCustomerData(CustomerItem customer) {
    setState(() {
      _idController.text        = customer.id;
      _custIdController.text    = customer.customerId;
      _firstNameController.text = customer.firstName;
      _lastNameController.text  = customer.lastName;
      _emailController.text     = customer.email;
      _mobileController.text    = customer.mobile;
      _altMobileController.text = customer.alternativeMobile;
      _genderController.text    = customer.gender;
      _regTypeController.text   = customer.registrationType;
      _statusController.text    = customer.status;
      
      _profileImageName = customer.profileImage.isNotEmpty ? 'Profile Image Loaded' : null;
      
      // Basic date parsing (assuming format or leaving null if empty)
      try {
        if (customer.createdAt.isNotEmpty) _createdAt = DateFormat('yyyy-MM-dd').parse(customer.createdAt.split(' ')[0]);
        if (customer.updatedAt.isNotEmpty) _updatedAt = DateFormat('yyyy-MM-dd').parse(customer.updatedAt.split(' ')[0]);
      } catch (_) {}

      _isFormVisible = true;
      _isGridView    = false;
    });
  }

  final Set<String> _expandedCustomerIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedCustomerIds.contains(id)) {
        _expandedCustomerIds.remove(id);
      } else {
        _expandedCustomerIds.add(id);
      }
    });
  }

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

    // Fetch customers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().fetchCustomers();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImageName = image.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Image Source',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF26A69A), size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCreatedAt) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isCreatedAt) {
          _createdAt = picked;
        } else {
          _updatedAt = picked;
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
          onPressed: () { if (Navigator.canPop(context)) { Navigator.pop(context); } },
        ),
        title: Row(
          children: [
            Text('Customer Details',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Text(
                'NEW',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        
      ),
      body: Stack(
        children: [
          // Content
          _isFormVisible ? _buildFormContent() : _buildGridViewContent(),

          // Save Button
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
                  ),
                  child: Text(
                    'Save Details',
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
                        _buildFabAction('New Customer', Icons.person_add_alt_1, onTap: () {
                          setState(() {
                            _isFormVisible = true;
                            _isGridView = false;
                            _toggleFab();
                          });
                        }),
                        const SizedBox(height: 16),
                        _buildFabAction('Customer List', Icons.people_outline, onTap: () {
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
                    _isFabExpanded ? Icons.close : Icons.group_outlined,
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
          child: Consumer<CustomerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
              }

              if (provider.errorMessage.isNotEmpty) {
                return _buildErrorView(provider.errorMessage, () => provider.fetchCustomers());
              }

              if (provider.customers.isEmpty) {
                return _buildEmptyView();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: provider.customers.length,
                itemBuilder: (context, index) {
                  final customer = provider.customers[index];
                  return _buildPremiumCustomerCard(customer);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCustomerCard(CustomerItem customer) {
    final bool isExpanded = _expandedCustomerIds.contains(customer.id);
    
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
          // Profile & Header Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF26A69A).withOpacity(0.2), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: customer.profileImage.isNotEmpty ? NetworkImage(customer.profileImage) : null,
                    child: customer.profileImage.isEmpty 
                      ? const Icon(Icons.person_outline, color: Color(0xFF26A69A), size: 30)
                      : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              customer.name.isEmpty ? '${customer.firstName} ${customer.lastName}' : customer.name,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
                            ),
                          ),
                          _buildStatusBadge(customer.status),
                        ],
                      ),
                      Text(
                        'UID: ${customer.customerId}',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          
          // Basic Contact Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.email_outlined, customer.email.isEmpty ? "No Email" : customer.email),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.phone_android, customer.mobile.isEmpty ? "No Mobile" : customer.mobile),
              ],
            ),
          ),

          // --- Expanded Detailed Information Card ---
          if (isExpanded)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.wc_outlined, 'Gender: ${customer.gender}')),
                      Expanded(child: _buildInfoRow(Icons.app_registration, 'Type: ${customer.registrationType}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.phone_android, 'Alt Mobile: ${customer.alternativeMobile.isEmpty ? 'N/A' : customer.alternativeMobile}'),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.tag, 'System ID: ${customer.id}'),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.calendar_today, 'Created: ${customer.createdAt}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildInfoRow(Icons.update, 'Updated: ${customer.updatedAt}')),
                    ],
                  ),
                ],
              ),
            ),
          
          // Action Buttons Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _buildQuickAction(Icons.call, 'Call', Colors.green, () {}),
                const SizedBox(width: 12),
                _buildQuickAction(Icons.mail_outline, 'Email', Colors.blue, () {}),
                const Spacer(),
                TextButton(
                  onPressed: () => _toggleExpand(customer.id),
                  child: Row(
                    children: [
                      Text(
                        isExpanded ? 'Show Less' : 'View Full Profile', 
                        style: GoogleFonts.poppins(color: const Color(0xFF26A69A), fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: const Color(0xFF26A69A)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.poppins(
          color: isActive ? Colors.green : Colors.orange,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
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
          Text(message, style: GoogleFonts.poppins(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
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
            child: const Icon(Icons.people_outline, color: Color(0xFF26A69A), size: 64),
          ),
          const SizedBox(height: 24),
          Text('No Customers Found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return SearchFilterBar(
      hintText: 'Search customers...',
      onSearchChanged: (value) {
        // Search logic here
      },
    );
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer Information', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        const SizedBox(height: 24),
        _buildInputCard('ID', 'ID', Icons.fingerprint, _idController),
        _buildInputCard('Customer Id', 'Customer Id', Icons.badge_outlined, _custIdController),
        _buildInputCard('Customer First Name', 'First Name', Icons.person_outline, _firstNameController),
        _buildInputCard('Customer Last Name', 'Last Name', Icons.person_outline, _lastNameController),
        _buildInputCard('Email', 'Email Address', Icons.email_outlined, _emailController),
        _buildInputCard('Mobile Number', 'Mobile Number', Icons.phone_android, _mobileController),
        _buildInputCard('Alternative Mobile Number', 'Alt Mobile Number', Icons.phone_android, _altMobileController),
        _buildInputCard('Gender', 'Gender (Male/Female)', Icons.wc_outlined, _genderController),
        
        _buildImageUploadCard('Profile Image'),
        
        _buildInputCard('Registration type', 'Registration type', Icons.app_registration, _regTypeController),
        _buildInputCard('Status', 'Status', Icons.info_outline, _statusController),
        
        _buildDateCard('Created at', _createdAt, Icons.calendar_today, () => _selectDate(context, true)),
        _buildDateCard('Updated at', _updatedAt, Icons.update, () => _selectDate(context, false)),
        
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildInputCard(String label, String hint, IconData icon, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: const Color(0xFF26A69A), size: 20),
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(String label, DateTime? date, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF26A69A), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    date != null ? DateFormat('dd-MM-yyyy').format(date!) : 'Select Date',
                    style: GoogleFonts.poppins(color: date != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(String label) {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.add_a_photo_outlined, color: Color(0xFF26A69A), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _profileImageName ?? 'Upload Profile Image',
                    style: GoogleFonts.poppins(color: _profileImageName != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF26A69A)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF26A69A), fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
