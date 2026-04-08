import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';
import '../utils/product_visuals.dart';

class ProductDetailScreen extends StatelessWidget {
  final ApiClient apiClient;
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.apiClient,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product detail')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF9F0),
              CustomerAppTheme.canvas,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 11, child: _buildVisualPanel()),
                            const SizedBox(width: 24),
                            Expanded(flex: 10, child: _buildInfoPanel(context)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVisualPanel(),
                            const SizedBox(height: 24),
                            _buildInfoPanel(context),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVisualPanel() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF1DFC7),
            Color(0xFFE4CAA0),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -36,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ProductArtwork(
                product: product,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            left: 22,
            bottom: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                product.stock > 10 ? 'Bestseller pick' : 'Limited batch',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context) {
    final inStock = product.stock > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (product.category != null) Chip(label: Text(product.category!)),
            Chip(
              backgroundColor:
                  (inStock ? CustomerAppTheme.success : CustomerAppTheme.danger)
                      .withValues(alpha: 0.12),
              label: Text(inStock ? 'In stock' : 'Currently unavailable'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.name,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 40),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium price',
                      style: TextStyle(
                        color: CustomerAppTheme.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatInr(product.price),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: CustomerAppTheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CustomerAppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${product.stock} units',
                  style: const TextStyle(
                    color: CustomerAppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          product.description ??
              'A considered catalog entry presented with richer retail framing for a more premium storefront experience.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ProductVisuals.highlights(product)
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: CustomerAppTheme.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _DetailCallout(
              icon: Icons.local_shipping_outlined,
              title: 'Concierge delivery',
              subtitle: 'Cash on delivery supported',
            ),
            _DetailCallout(
              icon: Icons.verified_outlined,
              title: 'Curated inventory',
              subtitle: 'Catalog managed by admin team',
            ),
            _DetailCallout(
              icon: Icons.devices_outlined,
              title: 'Responsive journey',
              subtitle: 'Built for desktop and mobile',
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailCallout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailCallout({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 260),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CustomerAppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: CustomerAppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CustomerAppTheme.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
