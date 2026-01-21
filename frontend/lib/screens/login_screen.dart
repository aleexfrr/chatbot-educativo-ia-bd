import 'package:flutter/material.dart';
import 'package:chatgva/screens/forgot_password_screen.dart';
import 'package:chatgva/screens/register_screen.dart';
import 'package:chatgva/utilities/utils.dart';
import 'package:chatgva/services/auth_service.dart';
import 'disabled_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool _isPasswordVisible = true;

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await _authService.loginWithEmail(email, password);

      if (!mounted) return;

      if (result.isDisabled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DisabledAccountScreen(),
          ),
        );
      } else if (result.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión exitoso')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _loginAsGuest() async {
    setState(() => isLoading = true);

    try {
      final result = await _authService.loginAsGuest();

      if (!mounted) return;

      if (result.isDisabled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DisabledAccountScreen()),
        );
      } else if (result.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has entrado como invitado')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintColor = theme.colorScheme.onSurface;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Color.fromRGBO(0, 0, 0, 0.3),),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      minHeight: 500,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage('assets/images/logo.png'),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "¡Bienvenido a XENOBOT!",
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Email
                          TextFormField(
                            controller: emailController,
                            style: TextStyle(color: hintColor),
                            keyboardType: TextInputType.emailAddress,
                            validator: Utils.validateEmail,
                            decoration: _inputDecoration(
                              'Correo electrónico',
                              hintColor,
                              Icons.email,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: _isPasswordVisible,
                            style: TextStyle(color: hintColor),
                            validator: Utils.validatePasswordSimple,
                            decoration: _inputDecoration(
                              'Contraseña',
                              hintColor,
                              Icons.lock,
                              isPassword: true,
                              isVisible: !_isPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Botón de inicio de sesión
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.brightness == Brightness.dark
                                    ? Colors.black12
                                    : Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.teal, // color del borde
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                  "Iniciar sesión",
                                  style: TextStyle(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.teal
                                          : Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Botón de invitado
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loginAsGuest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.brightness == Brightness.dark
                                    ? Colors.black12
                                    : Colors.teal,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.teal, // color del borde
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                  "Entrar como invitado",
                                  style: TextStyle(
                                      color: theme.brightness == Brightness.dark
                                          ? Colors.teal
                                          : Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                                "¿Has olvidado la contraseña?",
                                style: TextStyle(color: Colors.teal)
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                                "¿No tienes cuenta? Regístrate",
                                style: TextStyle(color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label,
      Color color,
      IconData icon, {
        bool isPassword = false,
        bool isVisible = false,
        VoidCallback? onToggle,
      }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color),
      prefixIcon: Icon(icon, color: color),
      errorStyle: const TextStyle(color: Colors.redAccent),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon(
          isVisible ? Icons.visibility_off : Icons.visibility,
          color: color,
        ),
        onPressed: onToggle,
      )
          : null,
    );
  }
}