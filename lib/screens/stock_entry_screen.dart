import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';

class StockEntryScreen extends StatefulWidget {
  final VoidCallback? onItemSaved;

  const StockEntryScreen({super.key, this.onItemSaved});

  @override
  State<StockEntryScreen> createState() => _StockEntryScreenState();
}

class _StockEntryScreenState extends State<StockEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _skuController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _reorderLevelController = TextEditingController();

  String? _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  @override
  void dispose() {
    _skuController.dispose();
    _itemNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  void _fillAcceptanceItem(String sku, String name, String category, int qty, double price, int reorder) {
    setState(() {
      _skuController.text = sku;
      _itemNameController.text = name;
      _selectedCategory = category;
      _quantityController.text = qty.toString();
      _unitPriceController.text = price.toStringAsFixed(2);
      _reorderLevelController.text = reorder.toString();
    });
  }

  Future<void> _handleSaveItem() async {
    // Task 1: Validation gate prevents any write when input is invalid
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct inline form errors before saving.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Task 2: Firestore write with correctly typed fields & server timestamp
      final sku = _skuController.text.trim().toUpperCase();
      final itemName = _itemNameController.text.trim();
      final category = _selectedCategory!;
      final quantity = int.parse(_quantityController.text.trim());
      final unitPrice = double.parse(_unitPriceController.text.trim());
      final reorderLevel = int.parse(_reorderLevelController.text.trim());

      final docRef = await FirestoreService().addStockItem(
        sku: sku,
        itemName: itemName,
        category: category,
        quantity: quantity,
        unitPrice: unitPrice,
        reorderLevel: reorderLevel,
      );

      if (!mounted) return;

      // Confirmation ONLY after acknowledged write
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Item $sku ($itemName) saved to Firestore! (ID: ${docRef.id.substring(0, 6)}...)'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      // Reset form upon confirmed success
      _formKey.currentState!.reset();
      _skuController.clear();
      _itemNameController.clear();
      _quantityController.clear();
      _unitPriceController.clear();
      _reorderLevelController.clear();
      setState(() {
        _selectedCategory = null;
      });

      widget.onItemSaved?.call();
    } catch (e) {
      if (!mounted) return;

      // Task 2: Handle write errors without clearing the form!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Firestore save failed: $e. Form data preserved.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              color: Colors.indigo.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.indigo.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_box_rounded, color: Colors.indigo.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Stock Item Entry Form',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All fields are required. Enter inventory item details and tap "Save Item" to record to Firestore.',
                      style: TextStyle(fontSize: 12, color: Colors.indigo.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Acceptance Test Fill Chips
            Text(
              'Acceptance Test Quick-Fill (Lecturer Data):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.flash_on, size: 14, color: Colors.blue),
                  label: const Text('STK-101 (USB Cable)', style: TextStyle(fontSize: 11)),
                  onPressed: () => _fillAcceptanceItem('STK-101', 'USB C Cable', 'Electronics', 4, 19.90, 5),
                ),
                ActionChip(
                  avatar: const Icon(Icons.flash_on, size: 14, color: Colors.amber),
                  label: const Text('STK-102 (Notebook)', style: TextStyle(fontSize: 11)),
                  onPressed: () => _fillAcceptanceItem('STK-102', 'Notebook', 'Stationery', 25, 4.50, 10),
                ),
                ActionChip(
                  avatar: const Icon(Icons.flash_on, size: 14, color: Colors.green),
                  label: const Text('STK-103 (Mouse)', style: TextStyle(fontSize: 11)),
                  onPressed: () => _fillAcceptanceItem('STK-103', 'Wireless Mouse', 'Electronics', 1, 35.00, 3),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. SKU Field
            TextFormField(
              controller: _skuController,
              enabled: !_isSaving,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'SKU *',
                hintText: 'e.g. STK-101',
                helperText: 'Format: STK- followed by three digits (e.g. STK-101)',
                prefixIcon: Icon(Icons.qr_code_2),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'SKU is required';
                }
                final regex = RegExp(r'^STK-\d{3}$');
                if (!regex.hasMatch(trimmed)) {
                  return 'Format must be STK- followed by 3 digits, e.g. STK-101';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 2. Item Name Field
            TextFormField(
              controller: _itemNameController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g. USB C Cable',
                helperText: 'Must be at least 3 characters',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Item name is required';
                }
                if (trimmed.length < 3) {
                  return 'Item name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 3. Category Selector Field
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                helperText: 'Select one permitted retail category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Choose category...'),
              items: _categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 4. Quantity Field
            TextFormField(
              controller: _quantityController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantity *',
                hintText: 'e.g. 10',
                helperText: 'Whole number, 0 or above',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Quantity is required';
                }
                final parsed = int.tryParse(trimmed);
                if (parsed == null) {
                  return 'Quantity must be a valid whole number';
                }
                if (parsed < 0) {
                  return 'Quantity must be 0 or above';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 5. Unit Price Field
            TextFormField(
              controller: _unitPriceController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Unit Price (RM) *',
                hintText: 'e.g. 19.90',
                helperText: 'RM amount greater than 0',
                prefixText: 'RM ',
                prefixIcon: Icon(Icons.payments_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Unit price is required';
                }
                final parsed = double.tryParse(trimmed);
                if (parsed == null) {
                  return 'Unit price must be a valid number';
                }
                if (parsed <= 0) {
                  return 'Unit price must be greater than RM 0.00';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 6. Reorder Level Field
            TextFormField(
              controller: _reorderLevelController,
              enabled: !_isSaving,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Reorder Level *',
                hintText: 'e.g. 5',
                helperText: 'Whole number, 0 or above (triggers low-stock alert)',
                prefixIcon: Icon(Icons.warning_amber_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Reorder level is required';
                }
                final parsed = int.tryParse(trimmed);
                if (parsed == null) {
                  return 'Reorder level must be a valid whole number';
                }
                if (parsed < 0) {
                  return 'Reorder level must be 0 or above';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save Item Button with Progress Indicator
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSaveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 22),
                label: Text(
                  _isSaving ? 'Saving to Firestore...' : 'Save Item',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
