import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/admin_app_theme.dart';

class ProductVisuals {
  /// Returns a category-matched Unsplash image URL for a grocery product.
  static String fallbackImageUrl(Product product) {
    final haystack = [
      product.name,
      product.category ?? '',
      product.description ?? '',
    ].join(' ').toLowerCase();

    if (haystack.contains('fruit') ||
        haystack.contains('apple') ||
        haystack.contains('mango') ||
        haystack.contains('banana') ||
        haystack.contains('orange') ||
        haystack.contains('grape') ||
        haystack.contains('berry') ||
        haystack.contains('watermelon')) {
      return 'https://images.unsplash.com/photo-1610832958506-aa56368176cf'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('vegetable') ||
        haystack.contains('spinach') ||
        haystack.contains('tomato') ||
        haystack.contains('onion') ||
        haystack.contains('potato') ||
        haystack.contains('carrot') ||
        haystack.contains('cabbage') ||
        haystack.contains('capsicum') ||
        haystack.contains('broccoli')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('dairy') ||
        haystack.contains('milk') ||
        haystack.contains('cheese') ||
        haystack.contains('butter') ||
        haystack.contains('curd') ||
        haystack.contains('yogurt') ||
        haystack.contains('paneer') ||
        haystack.contains('cream')) {
      return 'https://images.unsplash.com/photo-1563636619-e9143da7973b'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('bread') ||
        haystack.contains('bakery') ||
        haystack.contains('bun') ||
        haystack.contains('cake') ||
        haystack.contains('roti') ||
        haystack.contains('biscuit')) {
      return 'https://images.unsplash.com/photo-1509440159596-0249088772ff'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('beverage') ||
        haystack.contains('juice') ||
        haystack.contains('drink') ||
        haystack.contains('water') ||
        haystack.contains('coffee') ||
        haystack.contains('tea') ||
        haystack.contains('soda')) {
      return 'https://images.unsplash.com/photo-1544145945-f90425340c7e'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('snack') ||
        haystack.contains('chip') ||
        haystack.contains('namkeen') ||
        haystack.contains('popcorn') ||
        haystack.contains('cookie')) {
      return 'https://images.unsplash.com/photo-1566478989037-eec170784d0b'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('egg')) {
      return 'https://images.unsplash.com/photo-1587486913049-53fc22a7df5c'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('meat') ||
        haystack.contains('chicken') ||
        haystack.contains('mutton') ||
        haystack.contains('beef')) {
      return 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('fish') ||
        haystack.contains('prawn') ||
        haystack.contains('seafood') ||
        haystack.contains('shrimp')) {
      return 'https://images.unsplash.com/photo-1534482421-64566f976cfa'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('rice') ||
        haystack.contains('grain') ||
        haystack.contains('dal') ||
        haystack.contains('pulse') ||
        haystack.contains('lentil') ||
        haystack.contains('flour')) {
      return 'https://images.unsplash.com/photo-1586201375761-83865001e31c'
          '?w=400&h=400&fit=crop&q=80';
    }
    if (haystack.contains('spice') ||
        haystack.contains('masala') ||
        haystack.contains('oil') ||
        haystack.contains('sauce') ||
        haystack.contains('pickle')) {
      return 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d'
          '?w=400&h=400&fit=crop&q=80';
    }

    return 'https://images.unsplash.com/photo-1542838132-92c53300491e'
        '?w=400&h=400&fit=crop&q=80';
  }
}

class ProductArtwork extends StatelessWidget {
  final Product product;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductArtwork({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = (product.imageUrl != null && product.imageUrl!.isNotEmpty)
        ? product.imageUrl!
        : ProductVisuals.fallbackImageUrl(product);

    Widget image = Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: AdminAppTheme.pageBg,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AdminAppTheme.primaryGreen,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _buildIconFallback(context),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildIconFallback(BuildContext context) {
    return Container(
      color: AdminAppTheme.pageBg,
      child: Center(
        child: Icon(
          Icons.shopping_basket_outlined,
          size: 48,
          color: AdminAppTheme.primaryGreen.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
