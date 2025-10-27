import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_input_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  late final AnimationController _heroController;
  late final Animation<double> _heroAnimation;

  final _authService = AuthService();
  bool _isLogin = true;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      value: 0,
    );
    _heroAnimation = CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _heroController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      if (_isLogin) {
        _heroController.reverse();
      } else {
        _heroController.forward();
      }
    });
  }

  Future<void> _submitLogin() async {
    if (!_loginKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _authService.login(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      if (!mounted) return;
      final name = result.user['first_name'] as String?;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back${name == null || name.isEmpty ? '' : ', $name'}!')),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _authService.register(
        fullName: _registerNameController.text,
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
        confirmPassword: _registerConfirmPasswordController.text,
      );
      if (!mounted) return;
      final rawFirstName = (result.user['first_name'] as String?)?.trim();
      final displayName = (rawFirstName?.isNotEmpty ?? false)
          ? rawFirstName!
          : (result.user['email'] as String? ?? 'your account');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created for $displayName! Please sign in.')),
      );
      setState(() {
        _isLogin = true;
        _heroController.reverse();
        _loginEmailController.text = _registerEmailController.text;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AnimatedBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final maxCardWidth = math.min(constraints.maxWidth * (isWide ? 0.42 : 0.9), 460.0);

              return Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 40 : 24,
                      vertical: isWide ? 48 : 32,
                    ),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 36),
                                  child: _HeroCard(animation: _heroAnimation, isLogin: _isLogin),
                                ),
                              ),
                              SizedBox(
                                width: maxCardWidth,
                                child: _FormCard(
                                  isLogin: _isLogin,
                                  isSubmitting: _isSubmitting,
                                  onToggleMode: _toggleAuthMode,
                                  loginKey: _loginKey,
                                  registerKey: _registerKey,
                                  loginEmailController: _loginEmailController,
                                  loginPasswordController: _loginPasswordController,
                                  registerNameController: _registerNameController,
                                  registerEmailController: _registerEmailController,
                                  registerPasswordController: _registerPasswordController,
                                  registerConfirmPasswordController: _registerConfirmPasswordController,
                                  obscureLoginPassword: _obscureLoginPassword,
                                  obscureRegisterPassword: _obscureRegisterPassword,
                                  obscureRegisterConfirmPassword: _obscureRegisterConfirmPassword,
                                  onLoginPasswordVisibilityToggle: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                                  onRegisterPasswordVisibilityToggle: () =>
                                      setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
                                  onRegisterConfirmPasswordVisibilityToggle: () => setState(
                                    () => _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword,
                                  ),
                                  onSubmitLogin: _submitLogin,
                                  onSubmitRegister: _submitRegister,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 260,
                                child: _HeroCard(animation: _heroAnimation, isLogin: _isLogin),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: maxCardWidth,
                                child: _FormCard(
                                  isLogin: _isLogin,
                                  isSubmitting: _isSubmitting,
                                  onToggleMode: _toggleAuthMode,
                                  loginKey: _loginKey,
                                  registerKey: _registerKey,
                                  loginEmailController: _loginEmailController,
                                  loginPasswordController: _loginPasswordController,
                                  registerNameController: _registerNameController,
                                  registerEmailController: _registerEmailController,
                                  registerPasswordController: _registerPasswordController,
                                  registerConfirmPasswordController: _registerConfirmPasswordController,
                                  obscureLoginPassword: _obscureLoginPassword,
                                  obscureRegisterPassword: _obscureRegisterPassword,
                                  obscureRegisterConfirmPassword: _obscureRegisterConfirmPassword,
                                  onLoginPasswordVisibilityToggle: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                                  onRegisterPasswordVisibilityToggle: () =>
                                      setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
                                  onRegisterConfirmPasswordVisibilityToggle: () => setState(
                                    () => _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword,
                                  ),
                                  onSubmitLogin: _submitLogin,
                                  onSubmitRegister: _submitRegister,
                                ),
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
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.isLogin,
    required this.isSubmitting,
    required this.onToggleMode,
    required this.loginKey,
    required this.registerKey,
    required this.loginEmailController,
    required this.loginPasswordController,
    required this.registerNameController,
    required this.registerEmailController,
    required this.registerPasswordController,
    required this.registerConfirmPasswordController,
    required this.obscureLoginPassword,
    required this.obscureRegisterPassword,
    required this.obscureRegisterConfirmPassword,
    required this.onLoginPasswordVisibilityToggle,
    required this.onRegisterPasswordVisibilityToggle,
    required this.onRegisterConfirmPasswordVisibilityToggle,
    required this.onSubmitLogin,
    required this.onSubmitRegister,
  });

  final bool isLogin;
  final bool isSubmitting;
  final VoidCallback onToggleMode;
  final GlobalKey<FormState> loginKey;
  final GlobalKey<FormState> registerKey;
  final TextEditingController loginEmailController;
  final TextEditingController loginPasswordController;
  final TextEditingController registerNameController;
  final TextEditingController registerEmailController;
  final TextEditingController registerPasswordController;
  final TextEditingController registerConfirmPasswordController;
  final bool obscureLoginPassword;
  final bool obscureRegisterPassword;
  final bool obscureRegisterConfirmPassword;
  final VoidCallback onLoginPasswordVisibilityToggle;
  final VoidCallback onRegisterPasswordVisibilityToggle;
  final VoidCallback onRegisterConfirmPasswordVisibilityToggle;
  final Future<void> Function() onSubmitLogin;
  final Future<void> Function() onSubmitRegister;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthToggle(isLogin: isLogin, onToggleMode: onToggleMode),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            switchInCurve: Curves.easeOutExpo,
            switchOutCurve: Curves.easeInExpo,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: isLogin
                ? _LoginForm(
                    key: const ValueKey('login-form'),
                    formKey: loginKey,
                    emailController: loginEmailController,
                    passwordController: loginPasswordController,
                    obscurePassword: obscureLoginPassword,
                    onPasswordVisibilityToggle: onLoginPasswordVisibilityToggle,
                    onSubmit: onSubmitLogin,
                    isSubmitting: isSubmitting,
                  )
                : _RegisterForm(
                    key: const ValueKey('register-form'),
                    formKey: registerKey,
                    nameController: registerNameController,
                    emailController: registerEmailController,
                    passwordController: registerPasswordController,
                    confirmPasswordController: registerConfirmPasswordController,
                    obscurePassword: obscureRegisterPassword,
                    obscureConfirmPassword: obscureRegisterConfirmPassword,
                    onPasswordVisibilityToggle: onRegisterPasswordVisibilityToggle,
                    onConfirmPasswordVisibilityToggle: onRegisterConfirmPasswordVisibilityToggle,
                    onSubmit: onSubmitRegister,
                    isSubmitting: isSubmitting,
                  ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: const [
              _SocialButton(icon: Icons.g_translate, label: 'Google'),
              _SocialButton(icon: Icons.facebook, label: 'Facebook'),
              _SocialButton(icon: Icons.apple, label: 'Apple'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _AuthToggle extends StatelessWidget {
  const _AuthToggle({required this.isLogin, required this.onToggleMode});

  final bool isLogin;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(38),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _AuthToggleButton(
              label: 'Login',
              selected: isLogin,
              onTap: isLogin ? null : onToggleMode,
            ),
          ),
          Expanded(
            child: _AuthToggleButton(
              label: 'Register',
              selected: !isLogin,
              onTap: isLogin ? onToggleMode : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthToggleButton extends StatelessWidget {
  const _AuthToggleButton({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(32),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: selected ? Colors.white : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onPasswordVisibilityToggle,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onPasswordVisibilityToggle;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Let’s pick up right where you left off.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          AuthInputField(
            label: 'Email address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required.';
              final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegExp.hasMatch(value)) return 'Please enter a valid email.';
              return null;
            },
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: 'Password',
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required.';
              if (value.length < 8) return 'Password must be at least 8 characters.';
              return null;
            },
            suffix: IconButton(
              onPressed: onPasswordVisibilityToggle,
              icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSubmitting
                  ? SizedBox(
                      key: const ValueKey('login-progress'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Text('Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create account ✨',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Join our vibrant community and craft your workflow.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          AuthInputField(
            label: 'Full name',
            controller: nameController,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Let us know what to call you.';
              if (value.trim().length < 3) return 'Name must be at least 3 characters long.';
              return null;
            },
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: 'Email address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required.';
              final emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegExp.hasMatch(value)) return 'Please enter a valid email.';
              return null;
            },
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: 'Password',
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required.';
              if (value.length < 8) return 'Use at least 8 characters for security.';
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Include an uppercase letter for a stronger password.';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Include a number for a stronger password.';
              }
              return null;
            },
            suffix: IconButton(
              onPressed: onPasswordVisibilityToggle,
              icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          const SizedBox(height: 18),
          AuthInputField(
            label: 'Confirm password',
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password.';
              if (value != passwordController.text) return 'Passwords do not match.';
              return null;
            },
            suffix: IconButton(
              onPressed: onConfirmPasswordVisibilityToggle,
              icon: Icon(obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Receive curated product updates and productivity tips.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: isSubmitting ? null : onSubmit,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSubmitting
                  ? SizedBox(
                      key: const ValueKey('register-progress'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.animation, required this.isLogin});

  final Animation<double> animation;
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slideOffset = (1 - animation.value) * 40;
        return Transform.translate(
          offset: Offset(-slideOffset, 0),
          child: Opacity(opacity: 0.6 + (animation.value * 0.4), child: child),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(42),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 38,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              right: -40,
              top: -30,
              child: _GradientBlob(size: 160, opacity: 0.25),
            ),
            const Positioned(
              left: -20,
              bottom: -40,
              child: _GradientBlob(size: 200, opacity: 0.18),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 44, 36, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bolt, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('Powered by Material You', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: isLogin
                        ? Text(
                            key: const ValueKey('hero-login-title'),
                            'Discover a smoother way to stay on top of your day.',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.2),
                          )
                        : Text(
                            key: const ValueKey('hero-register-title'),
                            'Craft experiences that delight your customers from day one.',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.2),
                          ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: isLogin
                        ? Text(
                            key: const ValueKey('hero-login-desc'),
                            'Sign in to access personalized dashboards, smart reminders, and collaborative spaces tailor-made for you.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white.withOpacity(0.85), height: 1.5),
                          )
                        : Text(
                            key: const ValueKey('hero-register-desc'),
                            'Join thousands of makers building meaningful products with an intelligent toolkit that keeps teams in sync.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white.withOpacity(0.85), height: 1.5),
                          ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.24),
                          child: const Icon(Icons.spa_outlined, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            isLogin ? 'Mindful mode on' : 'New journeys begin',
                            key: ValueKey(isLogin),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
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

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFF3EB),
                Color.lerp(const Color(0xFFFFF3EB), const Color(0xFFFFC8B5), _controller.value * 0.7)!,
                const Color(0xFFFFF3EB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 120 + (_controller.value * 30),
                left: -90,
                child: const _BackgroundCircle(size: 220, color: Color(0x33FF9B71)),
              ),
              Positioned(
                bottom: 80,
                right: -40 + (_controller.value * 50),
                child: const _BackgroundCircle(size: 160, color: Color(0x33C9B6FF)),
              ),
              Positioned(
                top: -60,
                right: 120,
                child: _BackgroundCircle(
                  size: 260,
                  color: const Color(0x33FFCE89),
                  blurSigma: 120 * (0.6 + _controller.value * 0.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size, required this.color, this.blurSigma = 90});

  final double size;
  final Color color;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurSigma,
            spreadRadius: blurSigma / 4,
          ),
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  const _GradientBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.3,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.42),
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(opacity),
              Colors.white.withOpacity(opacity * 0.2),
              Colors.white.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}
