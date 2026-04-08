import 'package:flutter/material.dart';
import '../theme/customer_app_theme.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onOrdersTap;
  final bool isLoggedIn;

  const Navbar({
    super.key,
    required this.cartItemCount,
    this.searchQuery,
    this.onSearchChanged,
    this.onCartTap,
    this.onUserTap,
    this.onMenuTap,
    this.onOrdersTap,
    this.isLoggedIn = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return isMobile ? _buildMobileNav() : _buildDesktopNav();
  }

  Widget _buildMobileNav() {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: CustomerAppTheme.primaryGreen,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Icon(
          Icons.eco_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      title: const Text(
        'Gromuse',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        _DeliveryBadge(compact: true),
        const SizedBox(width: 4),
        if (isLoggedIn) _buildOrdersIcon(),
        const SizedBox(width: 4),
        _buildCartIcon(),
        const SizedBox(width: 4),
        _buildUserIcon(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopNav() {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: CustomerAppTheme.primaryGreen,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: const [
            Icon(Icons.eco_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
          ],
        ),
      ),
      leadingWidth: 48,
      title: const Text(
        'Gromuse',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        _DeliveryBadge(compact: false),
        const SizedBox(width: 16),
        if (isLoggedIn) _buildOrdersIcon(),
        if (isLoggedIn) const SizedBox(width: 12),
        _buildCartIcon(),
        const SizedBox(width: 12),
        _buildUserIcon(),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildCartIcon() {
    return Tooltip(
      message: 'Cart',
      child: InkWell(
        onTap: onCartTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 24,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: -6,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: CustomerAppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      cartItemCount > 99 ? '99+' : '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersIcon() {
    return Tooltip(
      message: 'My Orders',
      child: InkWell(
        onTap: onOrdersTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.receipt_long_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return Tooltip(
      message: isLoggedIn ? 'Sign Out' : 'Sign In',
      child: GestureDetector(
        onTap: onUserTap,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: isLoggedIn ? 0.6 : 0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  final bool compact;
  const _DeliveryBadge({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: CustomerAppTheme.accentLime.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomerAppTheme.accentLime.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            color: CustomerAppTheme.accentLime,
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            compact ? '10 min' : '10 min delivery',
            style: const TextStyle(
              color: CustomerAppTheme.accentLime,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
