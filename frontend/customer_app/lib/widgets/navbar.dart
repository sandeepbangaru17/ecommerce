import 'package:flutter/material.dart';
import '../theme/customer_app_theme.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final int cartItemCount;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onCartTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onMenuTap;
  final bool isLoggedIn;

  const Navbar({
    super.key,
    required this.cartItemCount,
    this.searchQuery,
    this.onSearchChanged,
    this.onCartTap,
    this.onUserTap,
    this.onMenuTap,
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
      flexibleSpace: Container(
        padding: const EdgeInsets.only(left: 56, right: 16, top: 50),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              hintText: "Search groceries...",
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 13,
              ),
              prefixIcon:
                  Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ),
      actions: [
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
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: "Search groceries, vegetables, fruits & more...",
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
              prefixIcon:
                  Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
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
