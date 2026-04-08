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
  bool _obscurePassword = true;

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
        SnackBar(
          content: Text(error.message),
          backgroundColor: CustomerAppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 500;

    return Scaffold(
      backgroundColor: CustomerAppTheme.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: isWide ? 420 : double.infinity),
              padding: EdgeInsets.all(isWide ? 36 : 24),
              decoration: BoxDecoration(
                color: CustomerAppTheme.cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 24,
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: CustomerAppTheme.addCartBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 38,
                      color: CustomerAppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Gromuse',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CustomerAppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    _isSignup
                        ? 'Create your account'
                        : 'Sign in to continue',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomerAppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildTabRow(),
                  const SizedBox(height: 24),
                  _buildFormFields(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomerAppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        disabledBackgroundColor:
                            CustomerAppTheme.primaryGreen.withValues(alpha: 0.6),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isSignup ? 'Create Account' : 'Sign In',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  if (_isSignup) ...[
                    const SizedBox(height: 16),
                    Text(
                      'By signing up, you agree to our Terms of Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: CustomerAppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabRow() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: CustomerAppTheme.addCartBg,
        borderRadius: BorderRadius.circular(23),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignup = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isSignup
                      ? CustomerAppTheme.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !_isSignup
                      ? [
                          BoxShadow(
                            blurRadius: 8,
                            color: CustomerAppTheme.primaryGreen
                                .withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: !_isSignup
                        ? Colors.white
                        : CustomerAppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignup = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isSignup
                      ? CustomerAppTheme.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isSignup
                      ? [
                          BoxShadow(
                            blurRadius: 8,
                            color: CustomerAppTheme.primaryGreen
                                .withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: _isSignup
                        ? Colors.white
                        : CustomerAppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_isSignup) ...[
            _buildTextField(
              controller: _nameController,
              hintText: 'Full Name',
              icon: Icons.person_outline_rounded,
              validator: (value) => null, // optional
            ),
            const SizedBox(height: 12),
          ],
          _buildTextField(
            controller: _emailController,
            hintText: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: CustomerAppTheme.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (_isSignup && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: CustomerAppTheme.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: CustomerAppTheme.pageBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: CustomerAppTheme.textSecondary.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: CustomerAppTheme.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CustomerAppTheme.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CustomerAppTheme.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }
}
