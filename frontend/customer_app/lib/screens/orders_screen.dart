import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/customer_app_theme.dart';
import '../utils/formatters.dart';

class OrdersScreen extends StatefulWidget {
  final ApiClient apiClient;

  const OrdersScreen({super.key, required this.apiClient});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await widget.apiClient.get('/orders');
      final orders = (response as List<dynamic>)
          .map((entry) => Order.fromJson(entry as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFC67B1C);
      case 'confirmed':
        return const Color(0xFF2D7DD2);
      case 'shipped':
        return const Color(0xFF7551C2);
      case 'delivered':
        return CustomerAppTheme.success;
      case 'cancelled':
        return CustomerAppTheme.danger;
      default:
        return CustomerAppTheme.muted;
    }
  }

  Future<void> _openOrderDetail(Order order) async {
    final response = await widget.apiClient.get('/orders/${order.id}');
    if (!mounted) return;
    final detailOrder = Order.fromJson(response as Map<String, dynamic>);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${shortOrderLabel(detailOrder.id)}',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            _StatusChip(
                              label: detailOrder.statusDisplay,
                              color: _statusColor(detailOrder.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DetailRow(
                          label: 'Total',
                          value: formatInr(detailOrder.totalAmount),
                        ),
                        _DetailRow(
                          label: 'Shipping',
                          value: detailOrder.shippingAddress,
                        ),
                        _DetailRow(
                          label: 'Phone',
                          value: detailOrder.contactPhone,
                        ),
                        if ((detailOrder.notes ?? '').isNotEmpty)
                          _DetailRow(
                            label: 'Notes',
                            value: detailOrder.notes!,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Items',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...detailOrder.items.map(
                          (item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: CustomerAppTheme.primary.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.productName ?? 'Product ${shortOrderLabel(item.productId)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: CustomerAppTheme.text,
                                    ),
                                  ),
                                ),
                                Text('Qty ${item.quantity}'),
                                const SizedBox(width: 14),
                                Text(
                                  formatInr(item.unitPrice),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CustomerAppTheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFBF5),
              CustomerAppTheme.canvas,
            ],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrders,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders yet',
          style: TextStyle(
            color: CustomerAppTheme.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => _openOrderDetail(order),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 620;
                    final info = [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${shortOrderLabel(order.id)}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Placed ${order.createdAt.toLocal().toString().split('.').first}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18, height: 18),
                      Column(
                        crossAxisAlignment: stacked
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          _StatusChip(
                            label: order.statusDisplay,
                            color: _statusColor(order.status),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            formatInr(order.totalAmount),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: CustomerAppTheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ];

                    return stacked
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: info,
                          )
                        : Row(children: info);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: CustomerAppTheme.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CustomerAppTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
