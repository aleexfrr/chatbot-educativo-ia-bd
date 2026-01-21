import 'package:flutter/material.dart';
import 'package:chatgva/utilities/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _forgotPassword() {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    print('Intentando recuperar cuenta:');
    print('Correo: $email');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se ha enviado el correo de recuperación correctamente.')),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hintColor = theme.colorScheme.onSurface;

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
            child: Container(color: Color.fromRGBO(0, 0, 0, 0.3),),
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
                            "¿Olvidaste tu contraseña?",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Introduce tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).toInt()),
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
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon: Icon(Icons.email, color: hintColor),
                              errorStyle: const TextStyle(color: Colors.redAccent),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: hintColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: hintColor, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón enviar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _forgotPassword,
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
                                "Enviar correo",
                                style: TextStyle(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.teal
                                        : Colors.white,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Volver al login
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Volver a inicio de sesión",
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
}