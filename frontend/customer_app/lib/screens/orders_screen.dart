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
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF8F00);
      case 'confirmed':
        return const Color(0xFF1565C0);
      case 'shipped':
        return const Color(0xFF6A1B9A);
      case 'delivered':
        return CustomerAppTheme.primaryGreen;
      case 'cancelled':
        return CustomerAppTheme.danger;
      default:
        return CustomerAppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.thumb_up_alt_outlined;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatOrderDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _openOrderDetail(Order order) async {
    try {
      final response = await widget.apiClient.get('/orders/${order.id}');
      if (!mounted) return;
      final detailOrder = Order.fromJson(response as Map<String, dynamic>);
      _showOrderDetailSheet(detailOrder);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: CustomerAppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showOrderDetailSheet(Order detailOrder) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: CustomerAppTheme.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CustomerAppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildOrderDetailContent(detailOrder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailContent(Order order) {
    final statusColor = _statusColor(order.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomerAppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatOrderDate(order.createdAt),
                    style: const TextStyle(
                      fontSize: 13,
                      color: CustomerAppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon(order.status), size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    _getDisplayStatus(order.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Delivery Address',
          order.shippingAddress,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.phone_outlined,
          'Contact',
          order.contactPhone,
        ),
        if ((order.notes ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(Icons.note_outlined, 'Notes', order.notes!),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1),
        ),
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CustomerAppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...order.items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomerAppTheme.pageBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Product image or placeholder
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CustomerAppTheme.addCartBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.productImageUrl != null &&
                          item.productImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.productImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.eco_rounded,
                              color: CustomerAppTheme.primaryGreen,
                              size: 22,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.eco_rounded,
                          color: CustomerAppTheme.primaryGreen,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName ?? 'Product',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CustomerAppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${formatInr(item.unitPrice)} × ${item.quantity}',
                        style: const TextStyle(
                          color: CustomerAppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatInr(item.unitPrice * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomerAppTheme.primaryGreen,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: CustomerAppTheme.textPrimary,
              ),
            ),
            Text(
              formatInr(order.totalAmount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: CustomerAppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomerAppTheme.addCartBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: CustomerAppTheme.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CustomerAppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: CustomerAppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: CustomerAppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        color: CustomerAppTheme.pageBg,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: CustomerAppTheme.primaryGreen,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CustomerAppTheme.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: CustomerAppTheme.danger,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Could not load orders',
                style: TextStyle(
                  color: CustomerAppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CustomerAppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CustomerAppTheme.addCartBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: CustomerAppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No orders yet',
                style: TextStyle(
                  color: CustomerAppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order history will appear here.\nStart shopping to place your first order!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomerAppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Browse Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomerAppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: CustomerAppTheme.primaryGreen,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;

          return isWide
              ? _buildWideOrderList()
              : _buildNarrowOrderList();
        },
      ),
    );
  }

  Widget _buildNarrowOrderList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
    );
  }

  Widget _buildWideOrderList() {
    // Use ListView with 2-column wrap to avoid fixed-height overflow
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: (_orders.length / 2).ceil(),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, rowIndex) {
        final leftIndex = rowIndex * 2;
        final rightIndex = leftIndex + 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildOrderCard(_orders[leftIndex])),
            const SizedBox(width: 12),
            if (rightIndex < _orders.length)
              Expanded(child: _buildOrderCard(_orders[rightIndex]))
            else
              const Expanded(child: SizedBox()),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final statusColor = _statusColor(order.status);
    return GestureDetector(
      onTap: () => _openOrderDetail(order),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CustomerAppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ← no unbounded expansion
          children: [
            // Row 1: status badge + order ID
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon(order.status),
                          size: 12, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        _getDisplayStatus(order.status),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    color: CustomerAppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // ← fixed gap, no Spacer
            // Row 2: items count + date
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 15,
                  color: CustomerAppTheme.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${order.itemCount} item${order.itemCount != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CustomerAppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatOrderDate(order.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: CustomerAppTheme.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3: total + chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatInr(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomerAppTheme.primaryGreen,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CustomerAppTheme.addCartBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: CustomerAppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
