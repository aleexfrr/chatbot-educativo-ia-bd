import 'package:flutter/material.dart';
import 'package:chatgva/utilities/utils.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validar que los campos no estén vacíos
    if (name.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true); // Activar estado de carga

    try {
      // Intentar registrar al usuario con nombre, apellido, email y contraseña
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        await _userService.createUserDocument(
          nombre: name,
          apellido: lastName,
          email: email,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso')),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen())
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        print(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false); // Desactivar estado de carga
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa oscura
          Positioned.fill(
            child: Container(color: Colors.black.withAlpha((0.3 * 255).toInt()),),
          ),
          // Contenido
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
                      minHeight: 550,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage('assets/icons/logo.png'),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            "Crea tu cuenta",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Nombre
                          TextFormField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            validator: Utils.validateName,
                            decoration: _inputDecoration("Nombre", Icons.person),
                          ),
                          const SizedBox(height: 20),
                          // Apellido
                          TextFormField(
                            controller: lastNameController,
                            style: const TextStyle(color: Colors.white),
                            validator: Utils.validateLastName,
                            decoration: _inputDecoration("Apellidos", Icons.person),
                          ),
                          const SizedBox(height: 20),

                          // Correo
                          TextFormField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            validator: Utils.validateEmail,
                            decoration: _inputDecoration("Correo electrónico", Icons.email),
                          ),
                          const SizedBox(height: 20),

                          // Contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            validator: Utils.validatePasswordSimple,
                            decoration: _inputDecoration(
                              "Contraseña",
                              Icons.lock,
                              isPassword: true,
                              isVisible: _isPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirmar contraseña
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value != passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(
                              "Confirmar contraseña",
                              Icons.lock_outline,
                              isPassword: true,
                              isVisible: _isConfirmPasswordVisible,
                              onToggle: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Botón
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Registrarse"),
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("¿Ya tienes cuenta? Inicia sesión"),
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
      IconData icon, {
        bool isPassword = false,
        bool isVisible = false,
        VoidCallback? onToggle,
      }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      errorStyle: const TextStyle(color: Colors.redAccent),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
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
          color: Colors.white,
        ),
        onPressed: onToggle,
      )
          : null,
    );
  }
}
