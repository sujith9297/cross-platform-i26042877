import 'package:flutter_test/flutter_test.dart';
import 'package:stock_inventory_app/main.dart';

void main() {
  testWidgets('App loads cleanly test', (WidgetTester tester) async {
    await tester.pumpWidget(const StockInventoryApp(
      firebaseReady: false,
    ));
    expect(find.text('Stock Inventory Manager'), findsOneWidget);
  });
}
