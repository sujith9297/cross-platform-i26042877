import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../services/firestore_service.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/stock_item_card.dart';

class InventoryListScreen extends StatefulWidget {
  final VoidCallback? onNavigateToEntry;

  const InventoryListScreen({super.key, this.onNavigateToEntry});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _keyword = '';
  String _selectedCategory = 'All';
  bool _lowStockOnly = false;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _keyword = '';
      _selectedCategory = 'All';
      _lowStockOnly = false;
      _sortAscending = true;
    });
  }

  /// Task 3: Filtering & Sorting logic
  /// Combines keyword (partial, case-insensitive on itemName OR sku),
  /// category filter, and low-stock filter (quantity <= reorderLevel) using AND.
  List<StockItem> _applyFiltersAndSort(List<StockItem> allItems) {
    final search = _keyword.trim().toLowerCase();

    final filtered = allItems.where((item) {
      // 1. Keyword filter (itemName OR sku, case-insensitive partial)
      final matchesKeyword = search.isEmpty ||
          item.itemName.toLowerCase().contains(search) ||
          item.sku.toLowerCase().contains(search);

      // 2. Category filter (All or specific match)
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.trim().toLowerCase() == _selectedCategory.toLowerCase();

      // 3. Low-stock only filter (quantity <= reorderLevel)
      final matchesLowStock = !_lowStockOnly || (item.quantity <= item.reorderLevel);

      // Combined filtering using AND between active controls
      return matchesKeyword && matchesCategory && matchesLowStock;
    }).toList();

    // 4. Sort visible results by quantity, ascending or descending
    filtered.sort((a, b) {
      final cmp = a.quantity.compareTo(b.quantity);
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StockItem>>(
      stream: FirestoreService().getStockItems(),
      builder: (context, snapshot) {
        // Task 5: Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading stock items from Firestore...',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Task 5: Error state handling without crashing
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Firestore Retrieval Error',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Connection'),
                  ),
                ],
              ),
            ),
          );
        }

        final allItems = snapshot.data ?? [];
        final visibleItems = _applyFiltersAndSort(allItems);

        return Column(
          children: [
            // Search, Category, Low-Stock Filter, and Sorting Controls
            SearchFilterBar(
              searchController: _searchController,
              selectedCategory: _selectedCategory,
              lowStockOnly: _lowStockOnly,
              sortAscending: _sortAscending,
              totalCount: allItems.length,
              filteredCount: visibleItems.length,
              onSearchChanged: (val) {
                setState(() {
                  _keyword = val;
                });
              },
              onCategoryChanged: (cat) {
                if (cat != null) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
              onLowStockChanged: (val) {
                setState(() {
                  _lowStockOnly = val;
                });
              },
              onToggleSort: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              onClearFilters: _clearFilters,
            ),

            // Inventory List or No-Results Message
            Expanded(
              child: allItems.isEmpty
                  ? _buildEmptyDatabaseView()
                  : visibleItems.isEmpty
                      ? _buildNoResultsView()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: visibleItems.length,
                          itemBuilder: (context, index) {
                            return StockItemCard(item: visibleItems[index]);
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyDatabaseView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Stock Items in Firestore',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your "stockItems" Firestore collection is currently empty. Use the Stock Entry tab to add items.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            if (widget.onNavigateToEntry != null)
              ElevatedButton.icon(
                onPressed: widget.onNavigateToEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add First Stock Item'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.orange.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Matching Stock Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No items matched the active search keywords, category ("$_selectedCategory"), or low-stock criteria.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
