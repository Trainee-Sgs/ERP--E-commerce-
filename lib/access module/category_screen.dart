import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import 'package:erp_ecommerce/widgets/search_filter_bar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  bool _isFabExpanded = false;
  bool _isFormVisible = false;
  String? _categoryImageName;
  DateTime? _entryDate;
  final ImagePicker _picker = ImagePicker();
  
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

    // Fetch categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCategories();
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
          _categoryImageName = image.name;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Image Source', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(Icons.camera_alt_outlined, 'Camera', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildSourceOption(Icons.photo_library_outlined, 'Gallery', () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF26A69A), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _entryDate = picked);
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
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2), // Category often maps to Product tab
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () { if (Navigator.canPop(context)) { Navigator.pop(context); } },
        ),
        title: Text(_isFormVisible ? 'Category Form' : 'Category Grid View', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          _isFormVisible ? _buildFormContent() : _buildGridViewContent(),

          if (_isFabExpanded)
            GestureDetector(
              onTap: _toggleFab,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          
          Positioned(
            right: 16,
            bottom: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ScaleTransition(
                  scale: _expandAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildFabAction('New Category', Icons.category_outlined, onTap: () {
                        setState(() { _isFormVisible = true; _toggleFab(); });
                      }),
                      const SizedBox(height: 16),
                      _buildFabAction('View All', Icons.grid_view_rounded, onTap: () {
                        setState(() { _isFormVisible = false; _toggleFab(); });
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                FloatingActionButton(
                  onPressed: _toggleFab,
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Icon(_isFabExpanded ? Icons.close : Icons.category, color: Colors.white),
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
              'Save Category',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
        Padding(padding: const EdgeInsets.all(16), child: _buildSearchRow()),
        Expanded(
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
              }

              if (categoryProvider.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(categoryProvider.errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => categoryProvider.fetchCategories(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (categoryProvider.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, color: Colors.grey, size: 48),
                      const SizedBox(height: 16),
                      Text('No categories found', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categoryProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.categories[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: category.logoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        category.logoUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, color: Color(0xFF26A69A), size: 30),
                                      ),
                                    )
                                  : const Icon(Icons.category, color: Color(0xFF26A69A), size: 30),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name.isEmpty ? 'Category ${index + 1}' : category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Brand: ${category.brand.isEmpty ? 'N/A' : category.brand}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11),
                                ),
                                const Spacer(),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildMiniInfo(Icons.qr_code, 'CODE: ${category.code.isEmpty ? "N/A" : category.code}'),
                                      const SizedBox(height: 4),
                                      _buildMiniInfo(Icons.tag, 'ID: ${category.id}'),
                                      const SizedBox(height: 4),
                                      _buildMiniInfo(Icons.calendar_today, 'DATE: ${category.entryDate.isEmpty ? "N/A" : category.entryDate}'),
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
      hintText: 'Search categories...',
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
          child: Text('Category Detail', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        ),
        _buildInputField('Category ID', 'Category ID'),
        _buildInputField('Category Code', 'Category Code'),
        _buildInputField('Brand', 'Brand'),
        _buildImageUploadField('Category Logo'),
        _buildDatePickerField('Entry Date', _entryDate, () => _selectDate(context)),
      ],
    );
  }

  Widget _buildInputField(String label, String hint) {
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: TextField(decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 13))),
            ),
          ],
        ),
      ),
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
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date != null ? DateFormat('dd-MM-yyyy').format(date!) : 'Select Date', style: TextStyle(color: date != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 13)),
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

  Widget _buildImageUploadField(String label) {
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
              onTap: _showImageSourceSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_categoryImageName ?? 'Select Category Logo', style: TextStyle(color: _categoryImageName != null ? const Color(0xFF1E293B) : const Color(0xFF94A3B8), fontSize: 13)),
                    const Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: const Color(0xFF26A69A)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFabAction(String label, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
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
