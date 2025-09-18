import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/auth_service.dart';
import '../widgets/ui_components.dart';

class SignupScreen extends StatefulWidget {
  final bool isDarkMode;

  const SignupScreen({super.key, required this.isDarkMode});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        context.read<AppStateProvider>().completeAuth();
      }
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.isDarkMode
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
              ),
        color: widget.isDarkMode ? const Color(0xFF121212) : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: widget.isDarkMode ? Colors.white : Colors.grey.shade700,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StyledCard(
              backgroundColor: widget.isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white.withValues(alpha: 0.8),
              borderColor: widget.isDarkMode
                  ? const Color(0xFF3A3A3A)
                  : Colors.white.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? const Color(0xFF03DAC6).withValues(alpha: 0.2)
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.flight,
                        size: 32,
                        color: widget.isDarkMode
                            ? const Color(0xFF03DAC6)
                            : Colors.green.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join DroneAssist and help deliver hope.',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDarkMode
                            ? const Color(0xFFE0E0E0)
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),

                    // Username Field
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                        fillColor: widget.isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                        fillColor: widget.isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                        fillColor: widget.isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.grey.shade600
                              : Colors.grey.shade500,
                        ),
                        fillColor: widget.isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey.shade50,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    StyledButton(
                      onPressed: _isLoading ? () {} : () => _handleSignup(),
                      backgroundColor: widget.isDarkMode
                          ? const Color(0xFFBB86FC)
                          : Colors.grey.shade900,
                      textColor: widget.isDarkMode ? Colors.black : Colors.white,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}