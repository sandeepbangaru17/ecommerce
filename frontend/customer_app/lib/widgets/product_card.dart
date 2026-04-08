import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/product_visuals.dart';
import 'add_to_cart_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Map<String, int> cart;
  final VoidCallback? onTap;
  final VoidCallback? onCartChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.cart,
    this.onTap,
    this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CustomerAppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ─────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CustomerAppTheme.addCartBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _ProductImage(product: product),
                      ),
                    ),
                  ),
                  if (product.stock > 0)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: CustomerAppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category ?? 'Fresh',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (product.stock == 0)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: CustomerAppTheme.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info area ───────────────────────────────────────────
            // Uses Flexible (not Expanded) so it can shrink without overflowing
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CustomerAppTheme.textPrimary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CustomerAppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '/unit',
                          style: TextStyle(
                            fontSize: 9,
                            color: CustomerAppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (product.stock > 0)
                      AddToCartButton(
                        product: product,
                        cart: cart,
                        onCartChanged: onCartChanged,
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 30,
                        decoration: BoxDecoration(
                          color: CustomerAppTheme.textSecondary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: CustomerAppTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final Product product;

  const _ProductImage({required this.product});

  @override
  Widget build(BuildContext context) {
    // If a real image URL is set, load it; otherwise show emoji
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => ProductEmojiDisplay(
          product: product,
          emojiSize: 36,
        ),
      );
    }
    return ProductEmojiDisplay(product: product, emojiSize: 36);
  }
}
