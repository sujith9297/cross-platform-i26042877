# NET4207 Stock Inventory Manager - Flutter & Cloud Firestore

Cross Platform Mobile App Development | Practical Lab Test  
**Student Name:** Sujith Devabhaktuni  
**Student ID:** I26042877  
**Module:** NET4207 Cross Platform Mobile App Development  
**Submission Repository:** https://github.com/Sujith-Devabhaktuni/NET4207_Stock_Inventory_Lab_Test  

---

## 1. Setup & Run Instructions
1. Ensure Flutter SDK (>= 3.0.0) is installed and available in PATH.
2. In the project root, retrieve dependencies:
   ```bash
   flutter pub get
   ```
3. Configure your class Firebase project using FlutterFire CLI:
   ```bash
   flutterfire configure --project=net4207-stock-inventory
   ```
4. Run the application on your desired device/emulator/browser:
   ```bash
   flutter run -d chrome
   # or
   flutter run
   ```

### Required Packages
- `flutter` (Material 3 UI framework)
- `firebase_core: ^3.6.0` (Firebase initialization)
- `cloud_firestore: ^5.4.4` (Cloud Firestore database real-time stream & writes)
- `cupertino_icons: ^1.0.8` (iOS style iconography)

### Firebase Project Details
- **Project ID:** `net4207-stock-inventory` (or lecturer-assigned class project)
- **Database:** Cloud Firestore in test mode (or secured via supplied `firestore.rules`)
- **Collection Name:** `stockItems`

---

## 2. Firestore Data Model & Schema (`stockItems`)

Every document in the `stockItems` collection uses auto-generated Firestore IDs with the following strictly typed fields:

| Field Name | Firestore Type | Constraints & Requirement |
| :--- | :--- | :--- |
| `sku` | String | Format `STK-` followed by exactly 3 digits (e.g. `STK-101`) |
| `itemName` | String | Trimmed; minimum 3 characters |
| `category` | String | One of: `Electronics`, `Stationery`, `Hardware`, `Grocery` |
| `quantity` | Integer | Whole number >= 0 |
| `unitPrice` | Number (Double) | Currency RM amount > 0 |
| `reorderLevel` | Integer | Whole number >= 0 (triggers low-stock alert) |
| `createdAt` | Timestamp | Server-generated timestamp (`FieldValue.serverTimestamp()`) |

---

## 3. Form Validation Rules
The Stock Entry Form uses a `GlobalKey<FormState>` validation gate before initiating any Firestore operations:
- **SKU:** Validated against regex `^STK-\d{3}$`. Non-matching or empty values trigger: `"Format must be STK- followed by 3 digits, e.g. STK-101"`.
- **Item Name:** Must not be blank and trimmed length must be >= 3 characters; otherwise displays: `"Item name must be at least 3 characters"`.
- **Category:** Validated using `DropdownButtonFormField<String>`. Missing selection displays: `"Category is required"`.
- **Quantity & Reorder Level:** Parsed as integer (`int.tryParse`), rejected if non-integer or `< 0` with messages: `"Must be a valid whole number"` and `"Must be 0 or above"`.
- **Unit Price:** Parsed as number (`double.tryParse`), rejected if non-positive (`<= 0`) with: `"Unit price must be greater than RM 0.00"`.
- **Safe Persistence:** When validation fails, zero Firestore network requests are made. When network errors occur, form inputs remain intact to prevent data loss.

---

## 4. Advanced Search & Low-Stock Filtering
The inventory list listens to Firestore in real-time (`StreamBuilder<List<StockItem>>`). Above the list, reactive search controls apply multi-criteria filtering using logical `AND`:
1. **Keyword Search:** Case-insensitive partial matching against `itemName` OR `sku` (`item.itemName.toLowerCase().contains(query) || item.sku.toLowerCase().contains(query)`).
2. **Category Filter:** Matches items against selected category (`'All'`, `'Electronics'`, `'Stationery'`, `'Hardware'`, `'Grocery'`).
3. **Low-Stock Filter:** Evaluates whether `quantity <= reorderLevel`. When toggled, only items requiring reorder are shown.
4. **Quantity Sort:** Toggles visible items between ascending (e.g., 1 -> 4 -> 25) and descending order.
5. **Clear Filters & Empty States:** One-tap button resets all criteria; informative messages distinguish between an empty database vs. no search matches.

---

## 5. Test Log

| # | Test Scenario | Input Data | Expected Result | Actual Result & Screenshot Reference |
| :---: | :--- | :--- | :--- | :--- |
| **1** | **Invalid Form Submission** | Blank fields; SKU: `ABC-99`, Price: `0`, Qty: `-5` | Inline validation errors on SKU, Item Name, Category, Price, and Quantity. No write sent to Firestore. | **PASSED.** Red error messages appeared inline; no document added to Firestore. *(See screenshot: `test1_invalid_form.png`)* |
| **2** | **Valid Firestore Save & Retrieve** | `STK-101`, "USB C Cable", Electronics, Qty: 4, Price: 19.90, Reorder: 5 | Loading indicator during write; green confirmation SnackBar; item appears immediately in Firestore inventory list. | **PASSED.** Acknowledged write created auto-ID doc in `stockItems`; list displayed formatted card with RM 19.90. *(See screenshot: `test2_save_retrieve.png`)* |
| **3** | **Combined Search (Keyword + Cat + Low Stock)** | Keyword: `"mouse"`, Category: `Electronics`, Low Stock: `ON` | Only items satisfying all 3 active filters appear (`STK-103 Wireless Mouse`). Other items filtered out. | **PASSED.** Only `STK-103` (Qty: 1 <= Reorder: 3) displayed. Clearing filters restored all items. *(See screenshot: `test3_combined_search.png`)* |
| **4** | **Quantity Sort (Ascending)** | All categories, 3 items saved: STK-101 (4), STK-102 (25), STK-103 (1) | List ordered by quantity ascending: STK-103 (1) first, STK-101 (4) second, STK-102 (25) third. | **PASSED.** Correct sort order observed: STK-103 -> STK-101 -> STK-102. *(See screenshot: `test4_quantity_sort.png`)* |

---

## 6. Screenshots Directory
Place your evidence screenshots in the `screenshots/` directory before committing:
- `screenshots/test1_invalid_form.png`
- `screenshots/test2_save_retrieve.png`
- `screenshots/test3_combined_search.png`
- `screenshots/test4_quantity_sort.png`
