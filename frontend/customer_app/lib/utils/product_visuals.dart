import '../models/models.dart';

/// Returns a product-specific Unsplash image URL based on name/category/description.
/// Multiple images per category — different products get different images via name hash.
class ProductVisuals {
  static String fallbackImageUrl(Product product) {
    final name = product.name.toLowerCase().trim();
    final category = (product.category ?? '').toLowerCase().trim();
    final description = (product.description ?? '').toLowerCase().trim();
    final haystack = '$name $category $description';

    // Hash based on product name so same product always gets same image
    // but different products within same category get different images
    final hash = name.codeUnits.fold(0, (a, b) => a + b);

    // ── Specific product name matching (highest priority) ──────────────

    if (_has(name, ['apple', 'seb'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(name, ['banana', 'kela'])) {
      return 'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['mango', 'aam'])) {
      return 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['watermelon', 'tarbuj'])) {
      return 'https://images.unsplash.com/photo-1571575173-b1b2cf8ccb7a?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['grape', 'angoor'])) {
      return 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['orange', 'narangi', 'santra'])) {
      return 'https://images.unsplash.com/photo-1547514701-57629cf1bea32?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['strawberry', 'strawberries'])) {
      return 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['pineapple', 'ananas'])) {
      return 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['tomato', 'tamatar'])) {
      return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['onion', 'pyaz', 'pyaaz'])) {
      return 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['potato', 'aloo', 'alu'])) {
      return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['carrot', 'gajar'])) {
      return 'https://images.unsplash.com/photo-1445282658-e2bb4c78a952?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['spinach', 'palak'])) {
      return 'https://images.unsplash.com/photo-1576045057-17c8835c56a5?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['capsicum', 'bell pepper', 'shimla mirch'])) {
      return 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['broccoli'])) {
      return 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cauliflower', 'gobi', 'gobhi'])) {
      return 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cabbage', 'patta gobi'])) {
      return 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cucumber', 'kheera', 'khira'])) {
      return 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['lemon', 'lime', 'nimbu'])) {
      return 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['garlic', 'lahsun'])) {
      return 'https://images.unsplash.com/photo-1501200291289-c5a76c232e5f?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['ginger', 'adrak'])) {
      return 'https://images.unsplash.com/photo-1615485290382-441b9052f434?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['milk', 'doodh'])) {
      return 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cheese', 'paneer'])) {
      return 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['butter', 'makhan'])) {
      return 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['curd', 'dahi', 'yogurt', 'yoghurt'])) {
      return 'https://images.unsplash.com/photo-1488477181152-c4e89f91dd3a?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cream', 'malai'])) {
      return 'https://images.unsplash.com/photo-1550583724-b4e7d5cd9f56?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['ghee'])) {
      return 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['egg', 'anda'])) {
      return 'https://images.unsplash.com/photo-1587486913049-53fc22a7df5c?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['bread', 'pav', 'bun', 'toast'])) {
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['cake', 'pastry'])) {
      return 'https://images.unsplash.com/photo-1578985545062-41c5e7a1a21f?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['biscuit', 'cookie', 'cracker'])) {
      return 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['roti', 'chapati', 'paratha', 'naan'])) {
      return 'https://images.unsplash.com/photo-1596458456260-7c53ec0df8cc?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['rice', 'chawal', 'basmati'])) {
      return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['dal', 'daal', 'lentil', 'pulse', 'moong', 'masoor', 'chana', 'urad', 'toor', 'arhar'])) {
      return 'https://images.unsplash.com/photo-1615485290382-441b9052f434?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['wheat', 'atta', 'gehun', 'flour', 'maida', 'besan', 'rava', 'suji', 'semolina'])) {
      return 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['chicken', 'murgi', 'murga'])) {
      return 'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['mutton', 'lamb', 'goat', 'bakra'])) {
      return 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['fish', 'machli', 'macchi', 'salmon', 'tuna', 'rohu', 'catla', 'hilsa'])) {
      return 'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['prawn', 'shrimp', 'jhinga', 'crab', 'lobster'])) {
      return 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['coffee', 'espresso', 'cappuccino', 'latte'])) {
      return 'https://images.unsplash.com/photo-1495474472359-6904f49ee6db?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['tea', 'chai', 'green tea', 'kadak'])) {
      return 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['juice', 'nimbu pani', 'lemonade', 'smoothie'])) {
      return 'https://images.unsplash.com/photo-1589733955941-5eeaf752f6dd?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['water', 'paani', 'mineral water', 'aqua'])) {
      return 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['soda', 'cola', 'pepsi', 'coke', 'sprite', 'cold drink', 'soft drink'])) {
      return 'https://images.unsplash.com/photo-1527960471264-932f39eb5846?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['oil', 'tel', 'sunflower oil', 'coconut oil', 'mustard oil', 'sarson', 'olive oil'])) {
      return 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['salt', 'namak', 'sugar', 'chini', 'shakkar'])) {
      return 'https://images.unsplash.com/photo-1472057533242-dfa1a8f1f7d5?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['spice', 'masala', 'haldi', 'turmeric', 'jeera', 'cumin', 'coriander', 'dhania', 'chilli', 'mirchi', 'pepper', 'kali mirch', 'cardamom', 'elaichi', 'cinnamon', 'dalchini', 'clove', 'laung'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506368083301-8231ac5e5bef?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(name, ['sauce', 'ketchup', 'chutney', 'pickle', 'achar', 'vinegar', 'mustard', 'mayo', 'mayonnaise'])) {
      return 'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['chips', 'chip', 'namkeen', 'popcorn', 'bhujia', 'mixture', 'chakli'])) {
      return 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['noodle', 'pasta', 'maggi', 'vermicelli', 'spaghetti'])) {
      return 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=400&h=400&fit=crop&q=80';
    }
    if (_has(name, ['soap', 'shampoo', 'detergent', 'washing', 'cleanser', 'toothpaste', 'toothbrush'])) {
      return 'https://images.unsplash.com/photo-1585652757173-8d8043f04d52?w=400&h=400&fit=crop&q=80';
    }

    // ── Category-level fallback with multiple images ───────────────────

    if (_has(haystack, ['fruit', 'fresh fruit', 'seasonal fruit'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['vegetable', 'veggie', 'sabzi', 'green'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1445282658-e2bb4c78a952?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['dairy', 'milk', 'cheese', 'butter', 'curd', 'yogurt', 'paneer', 'cream', 'ghee'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1488477181152-c4e89f91dd3a?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['bread', 'bakery', 'bun', 'cake', 'roti', 'biscuit', 'toast', 'pav'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1578985545062-41c5e7a1a21f?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['beverage', 'drink', 'juice', 'water', 'coffee', 'tea', 'soda', 'chai'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1495474472359-6904f49ee6db?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['snack', 'chip', 'namkeen', 'popcorn', 'cookie', 'cracker', 'bhujia'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['egg', 'anda'])) {
      return 'https://images.unsplash.com/photo-1587486913049-53fc22a7df5c?w=400&h=400&fit=crop&q=80';
    }
    if (_has(haystack, ['meat', 'chicken', 'mutton', 'beef', 'pork', 'lamb', 'murgi'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['fish', 'seafood', 'prawn', 'shrimp', 'machli', 'jhinga'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1534482421-64566f976cfa?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['rice', 'grain', 'dal', 'pulse', 'lentil', 'flour', 'atta', 'chawal', 'wheat', 'maida', 'besan'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1615485290382-441b9052f434?w=400&h=400&fit=crop&q=80',
      ]);
    }
    if (_has(haystack, ['spice', 'masala', 'oil', 'sauce', 'pickle', 'condiment', 'haldi', 'jeera', 'mirchi'])) {
      return _pick(hash, [
        'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop&q=80',
        'https://images.unsplash.com/photo-1506368083301-8231ac5e5bef?w=400&h=400&fit=crop&q=80',
      ]);
    }

    // ── Default: pick from multiple grocery images so not all same ─────
    return _pick(hash, [
      'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=400&h=400&fit=crop&q=80',
      'https://images.unsplash.com/photo-1608686207856-001b95cf60ca?w=400&h=400&fit=crop&q=80',
    ]);
  }

  /// Returns true if [text] contains any of [keywords]
  static bool _has(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  /// Picks a URL from [urls] consistently based on [hash]
  static String _pick(int hash, List<String> urls) {
    return urls[hash % urls.length];
  }
}
