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

  static List<String> highlights(Product product) {
    final haystack = [
      product.name,
      product.category ?? '',
      product.description ?? '',
    ].join(' ').toLowerCase();

    if (haystack.contains('headphone') || haystack.contains('audio')) {
      return const ['Spatial audio', '42-hour battery', 'Travel ready case'];
    }
    if (haystack.contains('watch') || haystack.contains('wearable')) {
      return const ['AMOLED display', 'Health metrics', 'Fast magnetic charge'];
    }
    if (haystack.contains('speaker')) {
      return const ['Deep bass tuning', 'Portable build', 'Room-filling output'];
    }
    if (haystack.contains('shirt') || haystack.contains('linen') || haystack.contains('apparel')) {
      return const ['Breathable weave', 'Tailored silhouette', 'All-day comfort'];
    }
    if (haystack.contains('shoe') || haystack.contains('sneaker') || haystack.contains('footwear')) {
      return const ['Cushioned sole', 'Daily wear build', 'Street-ready profile'];
    }

    return const ['Curated quality', 'Responsive storefront', 'Fast delivery ready'];
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
