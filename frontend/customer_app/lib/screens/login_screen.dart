import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/customer_app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiClient apiClient;
  final bool returnToPrevious;

  const LoginScreen({
    super.key,
    required this.apiClient,
    this.returnToPrevious = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isSignup = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await widget.apiClient.post(
        _isSignup ? '/auth/signup' : '/auth/login',
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          if (_isSignup && _nameController.text.trim().isNotEmpty)
            'full_name': _nameController.text.trim(),
        },
      );

      if (!mounted) return;

      widget.apiClient.setToken(response['access_token'] as String);
      if (widget.returnToPrevious && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(apiClient: widget.apiClient),
          ),
        );
      }
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
              Color(0xFFF7F1E8),
              Color(0xFFE8DCC9),
              Color(0xFFD8C2A4),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -20,
              child: _GlowOrb(
                size: 280,
                color: CustomerAppTheme.secondary.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -60,
              child: _GlowOrb(
                size: 320,
                color: CustomerAppTheme.primary.withValues(alpha: 0.12),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 920;
                        return wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 11, child: _buildBrandPanel()),
                                  const SizedBox(width: 28),
                                  Expanded(flex: 9, child: _buildFormCard()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildBrandPanel(compact: true),
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

  Widget _buildBrandPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 28 : 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomerAppTheme.primary,
            Color(0xFF0E2419),
            Color(0xFF1A4630),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomerAppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'AURUM COLLECTIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            compact
                ? 'Curated Indian luxury for modern everyday living.'
                : 'Shop a polished Indian storefront with concierge-style checkout.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 30 : 44,
              fontWeight: FontWeight.w700,
              height: 1.06,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            compact
                ? 'Sign in to explore premium picks, seamless cash-on-delivery ordering, and a refined product journey across mobile and desktop.'
                : 'Browse elevated essentials, track your orders, and move through a storefront designed to feel like a luxury retail lounge instead of a starter template.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _FeaturePill(
                icon: Icons.workspace_premium_outlined,
                label: 'Premium UI language',
              ),
              _FeaturePill(
                icon: Icons.currency_rupee,
                label: 'INR-first pricing',
              ),
              _FeaturePill(
                icon: Icons.devices_outlined,
                label: 'Mobile + desktop ready',
              ),
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
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: CustomerAppTheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignup ? 'Create your account' : 'Welcome back',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isSignup
                  ? 'Open your premium customer account to begin shopping.'
                  : 'Sign in to continue your curated shopping journey.',
            ),
            const SizedBox(height: 28),
            if (_isSignup) ...[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 18),
            ],
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
              validator: (value) => value == null || value.isEmpty
                  ? 'Password is required'
                  : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Text(_isSignup ? 'Create account' : 'Enter store'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  setState(() => _isSignup = !_isSignup);
                },
                child: Text(
                  _isSignup
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
