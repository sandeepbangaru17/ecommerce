import '../models/models.dart';

/// Returns a fallback Unsplash image URL for a grocery product
/// based on its name, category, or description.
class ProductVisuals {
  static String fallbackImageUrl(Product product) {
    final haystack = [
      product.name,
      product.category ?? '',
      product.description ?? '',
    ].join(' ').toLowerCase();

    // Fruits
    if (haystack.contains('fruit') ||
        haystack.contains('apple') ||
        haystack.contains('mango') ||
        haystack.contains('banana') ||
        haystack.contains('orange') ||
        haystack.contains('grape') ||
        haystack.contains('berry') ||
        haystack.contains('watermelon') ||
        haystack.contains('pineapple')) {
      return 'https://images.unsplash.com/photo-1610832958506-aa56368176cf'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Vegetables
    if (haystack.contains('vegetable') ||
        haystack.contains('spinach') ||
        haystack.contains('tomato') ||
        haystack.contains('onion') ||
        haystack.contains('potato') ||
        haystack.contains('carrot') ||
        haystack.contains('cabbage') ||
        haystack.contains('broccoli') ||
        haystack.contains('capsicum') ||
        haystack.contains('pepper')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Dairy
    if (haystack.contains('dairy') ||
        haystack.contains('milk') ||
        haystack.contains('cheese') ||
        haystack.contains('butter') ||
        haystack.contains('curd') ||
        haystack.contains('yogurt') ||
        haystack.contains('cream') ||
        haystack.contains('paneer')) {
      return 'https://images.unsplash.com/photo-1563636619-e9143da7973b'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Bread / Bakery
    if (haystack.contains('bread') ||
        haystack.contains('bakery') ||
        haystack.contains('bun') ||
        haystack.contains('cake') ||
        haystack.contains('roti') ||
        haystack.contains('biscuit') ||
        haystack.contains('toast')) {
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Beverages
    if (haystack.contains('beverage') ||
        haystack.contains('juice') ||
        haystack.contains('drink') ||
        haystack.contains('water') ||
        haystack.contains('soda') ||
        haystack.contains('coffee') ||
        haystack.contains('tea') ||
        haystack.contains('smoothie')) {
      return 'https://images.unsplash.com/photo-1544145945-f90425340c7e'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Snacks
    if (haystack.contains('snack') ||
        haystack.contains('chip') ||
        haystack.contains('namkeen') ||
        haystack.contains('popcorn') ||
        haystack.contains('cookie') ||
        haystack.contains('cracker')) {
      return 'https://images.unsplash.com/photo-1566478989037-eec170784d0b'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Eggs
    if (haystack.contains('egg')) {
      return 'https://images.unsplash.com/photo-1587486913049-53fc22a7df5c'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Meat
    if (haystack.contains('meat') ||
        haystack.contains('chicken') ||
        haystack.contains('mutton') ||
        haystack.contains('beef') ||
        haystack.contains('pork')) {
      return 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Fish / Seafood
    if (haystack.contains('fish') ||
        haystack.contains('prawn') ||
        haystack.contains('seafood') ||
        haystack.contains('shrimp')) {
      return 'https://images.unsplash.com/photo-1534482421-64566f976cfa'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Rice / Grains / Pulses
    if (haystack.contains('rice') ||
        haystack.contains('grain') ||
        haystack.contains('dal') ||
        haystack.contains('pulse') ||
        haystack.contains('lentil') ||
        haystack.contains('wheat') ||
        haystack.contains('flour')) {
      return 'https://images.unsplash.com/photo-1586201375761-83865001e31c'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Spices / Condiments
    if (haystack.contains('spice') ||
        haystack.contains('masala') ||
        haystack.contains('oil') ||
        haystack.contains('sauce') ||
        haystack.contains('pickle') ||
        haystack.contains('vinegar')) {
      return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d'
          '?w=400&h=400&fit=crop&q=80';
    }

    // Default grocery
    return 'https://images.unsplash.com/photo-1542838132-92c53300491e'
        '?w=400&h=400&fit=crop&q=80';
  }
}
