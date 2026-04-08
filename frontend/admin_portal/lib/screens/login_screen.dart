import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/admin_app_theme.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  final ApiClient apiClient;

  const AdminLoginScreen({super.key, required this.apiClient});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await widget.apiClient.post(
        '/auth/login',
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (!mounted) return;

      widget.apiClient.setToken(response['access_token'] as String);

      final profile = await widget.apiClient.get('/auth/me') as Map<String, dynamic>;
      if (!mounted) return;

      if ((profile['role'] as String? ?? 'user') != 'admin') {
        widget.apiClient.setToken(null);
        throw ApiException(403, 'This account is not an admin account.');
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(apiClient: widget.apiClient),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF091116),
              Color(0xFF102029),
              Color(0xFF142B35),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -80,
              top: 40,
              child: _AmbientOrb(
                size: 240,
                color: AdminAppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
            Positioned(
              right: -60,
              bottom: -40,
              child: _AmbientOrb(
                size: 300,
                color: AdminAppTheme.secondary.withValues(alpha: 0.1),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        return wide
                            ? Row(
                                children: [
                                  Expanded(flex: 11, child: _buildHero()),
                                  const SizedBox(width: 28),
                                  Expanded(flex: 9, child: _buildFormCard()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildHero(compact: true),
                                  const SizedBox(height: 20),
                                  _buildFormCard(),
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 28 : 38),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: AdminAppTheme.primary.withValues(alpha: 0.14),
            ),
            child: const Text(
              'AURUM CONTROL ROOM',
              style: TextStyle(
                color: AdminAppTheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            compact
                ? 'Premium operations for a premium storefront.'
                : 'Monitor catalog and order flow from a sharper, executive dashboard.',
            style: TextStyle(
              color: AdminAppTheme.text,
              fontSize: compact ? 30 : 42,
              fontWeight: FontWeight.w700,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Designed for desktop and mobile administration with richer data density, stronger hierarchy, and an INR-first retail language.',
            style: TextStyle(color: AdminAppTheme.muted, height: 1.6),
          ),
          const SizedBox(height: 26),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _AdminPill(icon: Icons.dashboard_customize_outlined, label: 'Executive dashboard'),
              _AdminPill(icon: Icons.currency_rupee, label: 'Indian pricing'),
              _AdminPill(icon: Icons.inventory_2_outlined, label: 'Catalog + orders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AdminAppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Admin sign in',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Authenticate to manage products, review orders, and update status flows.',
              style: TextStyle(color: AdminAppTheme.muted),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Enter dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _AdminPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AdminPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AdminAppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AdminAppTheme.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
