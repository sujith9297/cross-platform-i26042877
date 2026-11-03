import 'package:flutter/material.dart';
import 'stock_entry_screen.dart';
import 'inventory_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      StockEntryScreen(
        onItemSaved: () {
          // Stay on entry or allow user to switch to inventory
        },
      ),
      InventoryListScreen(
        onNavigateToEntry: () => _switchTab(0),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Inventory Manager',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'NET4207 ?¢ Cloud Firestore',
              style: TextStyle(fontSize: 11, color: Colors.indigo.shade100),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'About Lab Test',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('NET4207 Stock Inventory'),
                  content: const Text(
                    'Cross Platform Mobile App Development Lab Test\n\n'
                    '? Task 1: Stock Entry Form with complete validation\n'
                    '? Task 2: Cloud Firestore persistent storage & retrieval\n'
                    '? Task 3: Advanced search (SKU/name, Category, Low-stock, Quantity sort)\n'
                    '? Collection: stockItems\n'
                    '? Acceptance items: STK-101, STK-102, STK-103',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        indicatorColor: Colors.indigo.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart_outlined),
            selectedIcon: Icon(Icons.add_shopping_cart, color: Colors.indigo),
            label: 'Stock Entry',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: Colors.indigo),
            label: 'Inventory & Search',
          ),
        ],
      ),
    );
  }
}
