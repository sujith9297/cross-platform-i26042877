import 'package:cloud_firestore/cloud_firestore.dart';

class StockItem {
  final String id;
  final String sku;
  final String itemName;
  final String category;
  final int quantity;
  final double unitPrice;
  final int reorderLevel;
  final DateTime? createdAt;

  StockItem({
    required this.id,
    required this.sku,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.reorderLevel,
    this.createdAt,
  });

  /// Check if current stock has reached or fallen below reorder level
  bool get isLowStock => quantity <= reorderLevel;

  /// Formats unit price in Malaysian Ringgit (RM)
  String get formattedPrice => 'RM ${unitPrice.toStringAsFixed(2)}';

  /// Convert model instance to Map for Cloud Firestore write
  Map<String, dynamic> toFirestoreMap() {
    return {
      'sku': sku.trim().toUpperCase(),
      'itemName': itemName.trim(),
      'category': category.trim(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'reorderLevel': reorderLevel,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create model instance from Cloud Firestore DocumentSnapshot
  factory StockItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StockItem.fromMap(data, doc.id);
  }

  /// Create model instance from standard Map
  factory StockItem.fromMap(Map<String, dynamic> data, String id) {
    // Robust parsing for numbers from Firestore
    final rawQty = data['quantity'];
    final int qty = rawQty is int ? rawQty : (int.tryParse(rawQty?.toString() ?? '') ?? 0);

    final rawPrice = data['unitPrice'];
    final double price = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '') ?? 0.0);

    final rawReorder = data['reorderLevel'];
    final int reorder = rawReorder is int
        ? rawReorder
        : (int.tryParse(rawReorder?.toString() ?? '') ?? 0);

    DateTime? created;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is DateTime) {
      created = rawCreated;
    }

    return StockItem(
      id: id,
      sku: (data['sku'] ?? '').toString().trim(),
      itemName: (data['itemName'] ?? '').toString().trim(),
      category: (data['category'] ?? '').toString().trim(),
      quantity: qty,
      unitPrice: price,
      reorderLevel: reorder,
      createdAt: created,
    );
  }
}
