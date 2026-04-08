import 'package:flutter/material.dart';
import '../models/models.dart';

/// Returns product-matched emoji and background color.
/// No network images — fully offline, instant rendering.
class ProductVisuals {
  // ── Emoji ────────────────────────────────────────────────────────────

  static String fallbackEmoji(Product product) {
    final name = product.name.toLowerCase().trim();
    final category = (product.category ?? '').toLowerCase().trim();
    final h = '$name $category';

    if (_has(name, ['apple', 'seb'])) return '🍎';
    if (_has(name, ['banana', 'kela'])) return '🍌';
    if (_has(name, ['mango', 'aam'])) return '🥭';
    if (_has(name, ['watermelon', 'tarbuj'])) return '🍉';
    if (_has(name, ['grape', 'angoor'])) return '🍇';
    if (_has(name, ['orange', 'narangi', 'santra'])) return '🍊';
    if (_has(name, ['strawberry'])) return '🍓';
    if (_has(name, ['pineapple', 'ananas'])) return '🍍';
    if (_has(name, ['cherry'])) return '🍒';
    if (_has(name, ['pear', 'nashpati'])) return '🍐';
    if (_has(name, ['peach'])) return '🍑';
    if (_has(name, ['lemon', 'lime', 'nimbu'])) return '🍋';
    if (_has(name, ['coconut', 'nariyal'])) return '🥥';
    if (_has(name, ['tomato', 'tamatar'])) return '🍅';
    if (_has(name, ['onion', 'pyaz', 'pyaaz'])) return '🧅';
    if (_has(name, ['potato', 'aloo', 'alu'])) return '🥔';
    if (_has(name, ['carrot', 'gajar'])) return '🥕';
    if (_has(name, ['broccoli'])) return '🥦';
    if (_has(name, ['cauliflower', 'gobi', 'gobhi'])) return '🥦';
    if (_has(name, ['capsicum', 'bell pepper', 'shimla mirch'])) return '🫑';
    if (_has(name, ['corn', 'maize', 'makka'])) return '🌽';
    if (_has(name, ['eggplant', 'brinjal', 'baingan'])) return '🍆';
    if (_has(name, ['cabbage', 'patta gobi'])) return '🥬';
    if (_has(name, ['spinach', 'palak'])) return '🥬';
    if (_has(name, ['cucumber', 'kheera', 'khira'])) return '🥒';
    if (_has(name, ['garlic', 'lahsun'])) return '🧄';
    if (_has(name, ['ginger', 'adrak'])) return '🫚';
    if (_has(name, ['mushroom', 'khumb'])) return '🍄';
    if (_has(name, ['milk', 'doodh'])) return '🥛';
    if (_has(name, ['cheese', 'paneer'])) return '🧀';
    if (_has(name, ['butter', 'makhan'])) return '🧈';
    if (_has(name, ['curd', 'dahi', 'yogurt', 'yoghurt'])) return '🥛';
    if (_has(name, ['cream', 'malai'])) return '🍦';
    if (_has(name, ['ghee'])) return '🫙';
    if (_has(name, ['egg', 'anda'])) return '🥚';
    if (_has(name, ['bread', 'pav', 'bun', 'loaf'])) return '🍞';
    if (_has(name, ['cake', 'pastry'])) return '🎂';
    if (_has(name, ['biscuit', 'cookie', 'cracker'])) return '🍪';
    if (_has(name, ['roti', 'chapati', 'paratha', 'naan'])) return '🫓';
    if (_has(name, ['croissant'])) return '🥐';
    if (_has(name, ['rice', 'chawal', 'basmati'])) return '🍚';
    if (_has(name, ['dal', 'daal', 'lentil', 'pulse', 'moong', 'masoor', 'chana', 'urad', 'toor', 'arhar'])) return '🫘';
    if (_has(name, ['wheat', 'atta', 'gehun', 'flour', 'maida', 'besan', 'rava', 'suji'])) return '🌾';
    if (_has(name, ['oats', 'cereal', 'muesli'])) return '🌾';
    if (_has(name, ['chicken', 'murgi', 'murga'])) return '🍗';
    if (_has(name, ['mutton', 'lamb', 'goat', 'bakra', 'beef', 'pork'])) return '🥩';
    if (_has(name, ['fish', 'machli', 'macchi', 'salmon', 'tuna', 'rohu'])) return '🐟';
    if (_has(name, ['prawn', 'shrimp', 'jhinga', 'crab', 'lobster'])) return '🦐';
    if (_has(name, ['coffee', 'espresso', 'cappuccino'])) return '☕';
    if (_has(name, ['tea', 'chai', 'green tea'])) return '🍵';
    if (_has(name, ['juice', 'nimbu pani', 'lemonade', 'smoothie'])) return '🧃';
    if (_has(name, ['water', 'paani', 'mineral water'])) return '💧';
    if (_has(name, ['soda', 'cola', 'pepsi', 'coke', 'sprite', 'cold drink'])) return '🥤';
    if (_has(name, ['milkshake', 'shake'])) return '🥤';
    if (_has(name, ['oil', 'tel', 'sunflower', 'olive', 'coconut oil', 'mustard oil'])) return '🫙';
    if (_has(name, ['salt', 'namak'])) return '🧂';
    if (_has(name, ['sugar', 'chini', 'shakkar', 'jaggery', 'gud'])) return '🍬';
    if (_has(name, ['honey', 'shahad'])) return '🍯';
    if (_has(name, ['chilli', 'mirchi', 'pepper', 'kali mirch'])) return '🌶️';
    if (_has(name, ['masala', 'spice', 'haldi', 'turmeric', 'jeera', 'cumin', 'coriander', 'dhania', 'cardamom', 'elaichi', 'cinnamon', 'dalchini'])) return '🌶️';
    if (_has(name, ['sauce', 'ketchup', 'chutney', 'pickle', 'achar', 'mayo', 'mayonnaise'])) return '🍶';
    if (_has(name, ['chips', 'chip', 'namkeen', 'bhujia', 'mixture'])) return '🍟';
    if (_has(name, ['popcorn'])) return '🍿';
    if (_has(name, ['noodle', 'pasta', 'maggi', 'spaghetti'])) return '🍜';
    if (_has(name, ['pizza'])) return '🍕';
    if (_has(name, ['burger'])) return '🍔';
    if (_has(name, ['ice cream', 'icecream'])) return '🍨';
    if (_has(name, ['chocolate', 'choco'])) return '🍫';
    if (_has(name, ['soap', 'shampoo', 'detergent', 'washing', 'toothpaste', 'toothbrush'])) return '🧴';

    // Category-level fallback
    if (_has(h, ['fruit'])) return '🍎';
    if (_has(h, ['vegetable', 'veggie', 'sabzi'])) return '🥦';
    if (_has(h, ['dairy'])) return '🥛';
    if (_has(h, ['bakery', 'bread'])) return '🍞';
    if (_has(h, ['beverage', 'drink'])) return '🥤';
    if (_has(h, ['snack'])) return '🍿';
    if (_has(h, ['egg'])) return '🥚';
    if (_has(h, ['meat', 'chicken', 'mutton'])) return '🥩';
    if (_has(h, ['fish', 'seafood'])) return '🐟';
    if (_has(h, ['grain', 'rice', 'dal', 'pulse', 'flour'])) return '🌾';
    if (_has(h, ['spice', 'masala', 'oil', 'condiment'])) return '🌶️';

    return '🛒';
  }

  // ── Background colour ─────────────────────────────────────────────────

  static Color fallbackColor(Product product) {
    final name = product.name.toLowerCase().trim();
    final category = (product.category ?? '').toLowerCase().trim();
    final h = '$name $category';

    if (_has(h, ['fruit', 'apple', 'mango', 'banana', 'orange', 'grape', 'berry', 'watermelon', 'pineapple', 'lemon', 'cherry', 'peach', 'pear', 'coconut', 'strawberry'])) {
      return const Color(0xFFFFF8E1); // warm yellow
    }
    if (_has(h, ['vegetable', 'veggie', 'sabzi', 'tomato', 'onion', 'potato', 'carrot', 'broccoli', 'spinach', 'cabbage', 'cucumber', 'garlic', 'ginger', 'capsicum', 'corn', 'eggplant', 'cauliflower'])) {
      return const Color(0xFFF1F8E9); // soft green
    }
    if (_has(h, ['dairy', 'milk', 'cheese', 'butter', 'curd', 'yogurt', 'cream', 'paneer', 'ghee', 'doodh', 'dahi'])) {
      return const Color(0xFFE3F2FD); // light blue
    }
    if (_has(h, ['bakery', 'bread', 'bun', 'cake', 'roti', 'biscuit', 'cookie', 'pastry', 'naan', 'paratha', 'croissant'])) {
      return const Color(0xFFFFF3E0); // warm amber
    }
    if (_has(h, ['beverage', 'drink', 'juice', 'water', 'coffee', 'tea', 'soda', 'chai', 'smoothie', 'milkshake'])) {
      return const Color(0xFFF3E5F5); // soft purple
    }
    if (_has(h, ['snack', 'chip', 'namkeen', 'popcorn', 'bhujia', 'noodle', 'pasta'])) {
      return const Color(0xFFFBE9E7); // light orange
    }
    if (_has(h, ['egg', 'anda'])) {
      return const Color(0xFFFFFDE7); // pale yellow
    }
    if (_has(h, ['meat', 'chicken', 'mutton', 'beef', 'pork', 'lamb', 'murgi'])) {
      return const Color(0xFFFFEBEE); // light red
    }
    if (_has(h, ['fish', 'seafood', 'prawn', 'shrimp', 'crab'])) {
      return const Color(0xFFE0F7FA); // light teal
    }
    if (_has(h, ['rice', 'grain', 'dal', 'pulse', 'lentil', 'flour', 'atta', 'wheat', 'maida', 'besan', 'chawal'])) {
      return const Color(0xFFF9F6EE); // warm beige
    }
    if (_has(h, ['spice', 'masala', 'oil', 'sauce', 'pickle', 'salt', 'sugar', 'honey', 'condiment'])) {
      return const Color(0xFFFFF8F0); // light peach
    }

    return const Color(0xFFF5F5F5); // default light grey
  }

  static bool _has(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }
}

/// Drop-in widget that shows a product emoji on a soft colored background.
/// Use anywhere instead of Image.network.
class ProductEmojiDisplay extends StatelessWidget {
  final Product product;
  final double? width;
  final double? height;
  final double emojiSize;
  final BorderRadius? borderRadius;

  const ProductEmojiDisplay({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.emojiSize = 36,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = ProductVisuals.fallbackEmoji(product);
    final color = ProductVisuals.fallbackColor(product);

    Widget child = Container(
      width: width,
      height: height,
      color: color,
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: emojiSize),
      ),
    );

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }

    return child;
  }
}
