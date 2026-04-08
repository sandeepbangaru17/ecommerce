import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';

class AddToCartButton extends StatelessWidget {
  final Product product;
  final Map<String, int> cart;
  final VoidCallback? onCartChanged;

  const AddToCartButton({
    super.key,
    required this.product,
    required this.cart,
    this.onCartChanged,
  });

  int get _quantity => cart[product.id] ?? 0;

  void _addItem() {
    if (_quantity >= product.stock) return; // respect stock limit
    cart[product.id] = _quantity + 1;
    onCartChanged?.call();
  }

  void _removeItem() {
    if (_quantity > 0) {
      if (_quantity == 1) {
        cart.remove(product.id);
      } else {
        cart[product.id] = _quantity - 1;
      }
      onCartChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quantity == 0) {
      return GestureDetector(
        onTap: _addItem,
        child: Container(
          width: double.infinity,
          height: 32,
          decoration: BoxDecoration(
            color: CustomerAppTheme.addCartBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: CustomerAppTheme.primaryGreen,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'Add',
                style: TextStyle(
                  color: CustomerAppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        color: CustomerAppTheme.accentLime,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: _removeItem,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: CustomerAppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CustomerAppTheme.primaryGreen,
            ),
          ),
          GestureDetector(
            onTap: _quantity >= product.stock ? null : _addItem,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _quantity >= product.stock
                    ? CustomerAppTheme.textSecondary.withValues(alpha: 0.3)
                    : CustomerAppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
