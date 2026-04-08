import 'package:flutter/material.dart';

import '../models/models.dart';

class ProductVisuals {
  static String fallbackAsset(Product product) {
    final haystack = [
      product.name,
      product.category ?? '',
      product.description ?? '',
    ].join(' ').toLowerCase();

    if (haystack.contains('headphone') || haystack.contains('audio')) {
      return 'assets/products/headphones.png';
    }
    if (haystack.contains('watch') || haystack.contains('wearable')) {
      return 'assets/products/smartwatch.png';
    }
    if (haystack.contains('speaker')) {
      return 'assets/products/speaker.png';
    }
    if (haystack.contains('shirt') || haystack.contains('linen') || haystack.contains('apparel')) {
      return 'assets/products/shirt.png';
    }
    if (haystack.contains('shoe') || haystack.contains('sneaker') || haystack.contains('footwear')) {
      return 'assets/products/sneakers.png';
    }

    return 'assets/products/headphones.png';
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
    final fallback = Image.asset(
      ProductVisuals.fallbackAsset(product),
      fit: fit,
    );

    if ((product.imageUrl ?? '').isEmpty) {
      return borderRadius == null
          ? fallback
          : ClipRRect(borderRadius: borderRadius!, child: fallback);
    }

    final networkImage = Image.network(
      product.imageUrl!,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );

    return borderRadius == null
        ? networkImage
        : ClipRRect(borderRadius: borderRadius!, child: networkImage);
  }
}
