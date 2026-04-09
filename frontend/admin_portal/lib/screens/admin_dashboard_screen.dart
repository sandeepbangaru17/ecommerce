import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../theme/admin_app_theme.dart';
import '../utils/formatters.dart';
import '../utils/product_visuals.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ApiClient apiClient;

  const AdminDashboardScreen({super.key, required this.apiClient});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 24,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gromuse Admin',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 2),
            Text(
              'Store management',
              style: TextStyle(fontSize: 13, color: AdminAppTheme.muted),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                widget.apiClient.setToken(null);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AdminLoginScreen(apiClient: widget.apiClient),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF101920),
              AdminAppTheme.canvas,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF17262E),
                        Color(0xFF1E313C),
                        Color(0xFF10313E),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GROMUSE ADMIN',
                        style: TextStyle(
                          color: AdminAppTheme.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Manage your products, pricing and orders.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 18),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Products', icon: Icon(Icons.inventory_2_outlined)),
                          Tab(text: 'Orders', icon: Icon(Icons.local_shipping_outlined)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ProductsTab(apiClient: widget.apiClient),
                      OrdersTab(apiClient: widget.apiClient),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductsTab extends StatefulWidget {
  final ApiClient apiClient;

  const ProductsTab({super.key, required this.apiClient});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _loadError;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      // No is_active filter — admin sees all products including hidden ones
      final response = await widget.apiClient.get('/products');
      final products = (response as List<dynamic>)
          .map((entry) => Product.fromJson(entry as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load products';
        _isLoading = false;
      });
    }
  }

  List<String> get _categories => [
        'All',
        ..._products
            .map((item) => item.category?.trim())
            .whereType<String>()
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort(),
      ];

  List<Product> get _visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' ||
          (product.category ?? '').toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          (product.description ?? '').toLowerCase().contains(query) ||
          (product.category ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _showProductDialog({Product? product}) {
    final isEdit = product != null;
    final nameController = TextEditingController(text: product?.name);
    final descriptionController = TextEditingController(text: product?.description);
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stock.toString());
    final categoryController = TextEditingController(text: product?.category);
    final imageUrlController = TextEditingController(text: product?.imageUrl);
    bool isActive = product?.isActive ?? true;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: AdminAppTheme.surfaceRaised,
            title: Text(isEdit ? 'Edit product' : 'Add product'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price in INR'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available in storefront'),
                      value: isActive,
                      onChanged: (value) => setDialogState(() => isActive = value),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              if (isEdit)
                TextButton(
                  onPressed: () async {
                    try {
                      await widget.apiClient.delete('/products/${product.id}');
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      _loadProducts();
                    } catch (error) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('$error')),
                      );
                    }
                  },
                  child: const Text('Delete'),
                ),
              ElevatedButton(
                onPressed: () async {
                  // Validate fields before saving
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Product name is required')),
                    );
                    return;
                  }
                  final price = double.tryParse(priceController.text);
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid price greater than 0')),
                    );
                    return;
                  }
                  final stock = int.tryParse(stockController.text);
                  if (stock == null || stock < 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Stock must be 0 or more')),
                    );
                    return;
                  }
                  try {
                    final body = {
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      'price': price,
                      'stock': stock,
                      'category': categoryController.text.trim().isEmpty
                          ? null
                          : categoryController.text.trim(),
                      'image_url': imageUrlController.text.trim().isEmpty
                          ? null
                          : imageUrlController.text.trim(),
                      'is_active': isActive,
                    };
                    if (isEdit) {
                      await widget.apiClient.put('/products/${product.id}', body: body);
                    } else {
                      await widget.apiClient.post('/products', body: body);
                    }
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _loadProducts();
                  } catch (error) {
                    if (!dialogContext.mounted) return;
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('$error')),
                    );
                  }
                },
                child: Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          );
        },
      ),
    );
  }  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AdminAppTheme.muted),
              const SizedBox(height: 16),
              Text(_loadError!,
                  style: const TextStyle(color: AdminAppTheme.muted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final activeProducts = _products.where((product) => product.isActive).length;
    final totalValue = _products.fold<double>(
      0,
      (sum, product) => sum + (product.price * product.stock),
    );
    final visibleProducts = _visibleProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1240
            ? 3
            : constraints.maxWidth >= 760
                ? 2
                : 1;

        return RefreshIndicator(
          onRefresh: _loadProducts,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: constraints.maxWidth >= 760 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _AdminMetricCard(
                      label: 'Catalog value',
                      value: formatInr(totalValue),
                      icon: Icons.currency_rupee,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth >= 760 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _AdminMetricCard(
                      label: 'Active products',
                      value: '$activeProducts',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth >= 760 ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                    child: _AdminMetricCard(
                      label: 'Total products',
                      value: '${_products.length}',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, box) {
                          final stacked = box.maxWidth < 860;
                          final search = TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Search catalog, category, or description',
                              prefixIcon: Icon(Icons.search_rounded),
                            ),
                          );
                          final createButton = ElevatedButton.icon(
                            onPressed: () => _showProductDialog(),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add product'),
                          );
                          return stacked
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    search,
                                    const SizedBox(height: 12),
                                    createButton,
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: search),
                                    const SizedBox(width: 14),
                                    createButton,
                                  ],
                                );
                        },
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categories
                            .map(
                              (category) => ChoiceChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (_) => setState(() => _selectedCategory = category),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (visibleProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, color: AdminAppTheme.muted, size: 46),
                        const SizedBox(height: 12),
                        Text(
                          'No products match this filter',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 0.85 : columns == 2 ? 0.88 : 0.82,
                  ),
                  itemCount: visibleProducts.length,
                  itemBuilder: (context, index) {
                    final product = visibleProducts[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => _showProductDialog(product: product),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 130,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white.withValues(alpha: 0.04),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ProductArtwork(
                                          product: product,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      top: 12,
                                      child: _StatusBadge(
                                        label: product.isActive ? 'Live' : 'Hidden',
                                        color: product.isActive
                                            ? AdminAppTheme.secondary
                                            : AdminAppTheme.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: Theme.of(context).textTheme.titleLarge,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    formatInr(product.price),
                                    style: const TextStyle(
                                      color: AdminAppTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                product.description ?? 'No description added',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AdminAppTheme.muted),
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Chip(label: Text(product.category ?? 'General')),
                                  Chip(label: Text('Stock ${product.stock}')),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.imageUrl?.isNotEmpty == true
                                          ? 'Custom image set'
                                          : 'Auto emoji artwork',
                                      style: const TextStyle(color: AdminAppTheme.muted),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _showProductDialog(product: product),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class OrdersTab extends StatefulWidget {
  final ApiClient apiClient;

  const OrdersTab({super.key, required this.apiClient});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
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
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Failed to load orders';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFC67B1C);
      case 'confirmed':
        return const Color(0xFF46A0FF);
      case 'shipped':
        return const Color(0xFFA186FF);
      case 'delivered':
        return AdminAppTheme.secondary;
      case 'cancelled':
        return AdminAppTheme.danger;
      default:
        return AdminAppTheme.muted;
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    await widget.apiClient.put(
      '/orders/$orderId/status',
      body: {'status': status},
    );
    await _loadOrders();
  }

  Future<void> _openOrderDetail(Order order) async {
    final response = await widget.apiClient.get('/orders/${order.id}');
    if (!mounted) return;
    final detail = Order.fromJson(response as Map<String, dynamic>);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AdminAppTheme.surfaceRaised,
        title: Text('Order #${shortOrderLabel(detail.id)}'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(
                  label: detail.statusDisplay,
                  color: _statusColor(detail.status),
                ),
                const SizedBox(height: 14),
                _InfoRow(label: 'Total', value: formatInr(detail.totalAmount)),
                _InfoRow(label: 'Shipping', value: detail.shippingAddress),
                _InfoRow(label: 'Phone', value: detail.contactPhone),
                if ((detail.notes ?? '').isNotEmpty)
                  _InfoRow(label: 'Notes', value: detail.notes!),
                const SizedBox(height: 16),
                const Text(
                  'Items',
                  style: TextStyle(
                    color: AdminAppTheme.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ...detail.items.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? shortOrderLabel(item.productId),
                          ),
                        ),
                        Text('Qty ${item.quantity}'),
                        const SizedBox(width: 12),
                        Text(formatInr(item.unitPrice)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (detail.status == 'pending')
            ElevatedButton(
              onPressed: () async {
                await _updateStatus(detail.id, 'confirmed');
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Confirm'),
            ),
          if (detail.status == 'confirmed')
            ElevatedButton(
              onPressed: () async {
                await _updateStatus(detail.id, 'shipped');
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Ship'),
            ),
          if (detail.status == 'shipped')
            ElevatedButton(
              onPressed: () async {
                await _updateStatus(detail.id, 'delivered');
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Mark success'),
            ),
          if (detail.status != 'delivered' && detail.status != 'cancelled')
            TextButton(
              onPressed: () async {
                await _updateStatus(detail.id, 'cancelled');
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AdminAppTheme.muted),
              const SizedBox(height: 16),
              Text(_loadError!,
                  style: const TextStyle(color: AdminAppTheme.muted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final totalRevenue = _orders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AdminMetricCard(
                label: 'Orders',
                value: '${_orders.length}',
                icon: Icons.shopping_bag_outlined,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AdminMetricCard(
                label: 'Revenue tracked',
                value: formatInr(totalRevenue),
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView.separated(
              itemCount: _orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _openOrderDetail(order),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
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
                                  'User ${shortOrderLabel(order.userId)}',
                                  style: const TextStyle(color: AdminAppTheme.muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _StatusBadge(
                            label: order.statusDisplay,
                            color: _statusColor(order.status),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            formatInr(order.totalAmount),
                            style: const TextStyle(
                              color: AdminAppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _AdminMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AdminAppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AdminAppTheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: AdminAppTheme.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(color: AdminAppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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
              style: const TextStyle(color: AdminAppTheme.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AdminAppTheme.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
