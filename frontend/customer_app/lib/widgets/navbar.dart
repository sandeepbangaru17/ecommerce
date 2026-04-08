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
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      return _buildMobileNav();
    } else {
      return _buildDesktopNav();
    }
  }

  Widget _buildMobileNav() {
    return AppBar(
      toolbarHeight: 70,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: onMenuTap,
      ),
      title: const Text(
        "Gromuse",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomerAppTheme.accentLime.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: CustomerAppTheme.accentLime,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "10 min",
                      style: TextStyle(
                        color: CustomerAppTheme.accentLime,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildOrdersIcon(),
        const SizedBox(width: 8),
        _buildCartIcon(),
        const SizedBox(width: 8),
        _buildUserIcon(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDesktopNav() {
    return AppBar(
      toolbarHeight: 70,
      leading: Container(
        padding: const EdgeInsets.only(left: 20),
        child: const Text(
          "Gromuse",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      leadingWidth: 140,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CustomerAppTheme.accentLime.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: CustomerAppTheme.accentLime,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "10 min delivery",
                      style: TextStyle(
                        color: CustomerAppTheme.accentLime,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildOrdersIcon(),
        const SizedBox(width: 12),
        _buildCartIcon(),
        const SizedBox(width: 12),
        _buildUserIcon(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCartIcon() {
    return InkWell(
      onTap: onCartTap,
      borderRadius: BorderRadius.circular(20),
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
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: CustomerAppTheme.danger,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  '$cartItemCount',
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
    );
  }

  Widget _buildOrdersIcon() {
    return InkWell(
      onTap: onOrdersTap,
      borderRadius: BorderRadius.circular(20),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.receipt_long_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildUserIcon() {
    return GestureDetector(
      onTap: onUserTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLoggedIn ? Icons.person : Icons.person_outline,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
