import 'package:flutter/material.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final bool lowStockOnly;
  final bool sortAscending;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onLowStockChanged;
  final VoidCallback onToggleSort;
  final VoidCallback onClearFilters;
  final int totalCount;
  final int filteredCount;

  static const List<String> categories = [
    'All',
    'Electronics',
    'Stationery',
    'Hardware',
    'Grocery',
  ];

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.lowStockOnly,
    required this.sortAscending,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onLowStockChanged,
    required this.onToggleSort,
    required this.onClearFilters,
    required this.totalCount,
    required this.filteredCount,
  });

  bool get hasActiveFilters =>
      searchController.text.trim().isNotEmpty ||
      selectedCategory != 'All' ||
      lowStockOnly ||
      !sortAscending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Keyword search input
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search SKU (e.g. STK-101) or Name...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Category Filter & Sort Toggle Row
          Row(
            children: [
              // Category Dropdown
              Expanded(
                flex: 5,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 8),

              // Sort by Quantity Button (Ascending / Descending)
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: onToggleSort,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(
                      color: !sortAscending ? Colors.indigo : Colors.grey.shade400,
                    ),
                    backgroundColor: !sortAscending ? Colors.indigo.shade50 : null,
                  ),
                  icon: Icon(
                    sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: !sortAscending ? Colors.indigo : Colors.black87,
                  ),
                  label: Text(
                    sortAscending ? 'Qty: Asc' : 'Qty: Desc',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: !sortAscending ? Colors.indigo : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 3. Low-stock switch + Clear Filters + Item Count
          Row(
            children: [
              // Low stock filter chip/switch
              FilterChip(
                selected: lowStockOnly,
                label: const Text('Low stock only (Qty \u2264 Reorder)', style: TextStyle(fontSize: 12)),
                avatar: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: lowStockOnly ? Colors.white : Colors.red.shade700,
                ),
                selectedColor: Colors.red.shade700,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: lowStockOnly ? Colors.white : Colors.black87,
                  fontWeight: lowStockOnly ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: onLowStockChanged,
              ),
              const Spacer(),

              // Clear Filters button
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.red.shade700,
                  ),
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),

          // Count status
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Showing $filteredCount of $totalCount items in Firestore',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
