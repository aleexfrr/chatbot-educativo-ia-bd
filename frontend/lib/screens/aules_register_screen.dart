import 'package:flutter/material.dart';
import '../services/aules_service.dart';

class AulesRegisterScreen extends StatefulWidget {
  const AulesRegisterScreen({super.key});

  @override
  State<AulesRegisterScreen> createState() => _AulesRegisterScreenState();
}

class _AulesRegisterScreenState extends State<AulesRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== Listas estáticas y dinámicas =====
  final List<String> _provincias = ['Valencia', 'Castellón', 'Alicante'];
  final Map<String, List<String>> _pueblos = {
    'Valencia': ['Valencia', 'Xàtiva', 'Alzira'],
    'Castellón': ['Castellón', 'Vinaròs', 'Segorbe'],
    'Alicante': ['Alicante', 'Elche', 'Denia'],
  };
  final Map<String, List<String>> _instituts = {
    'Valencia': ['IES Lluís Vives', 'IES Xàtiva', 'IES Alzira'],
    'Xàtiva': ['IES Xàtiva 1', 'IES Xàtiva 2'],
    'Alzira': ['IES Alzira 1', 'IES Alzira 2'],
    'Castellón': ['IES Castellón 1'],
    'Vinaròs': ['IES Vinaròs'],
    'Segorbe': ['IES Segorbe'],
    'Alicante': ['IES Alicante 1'],
    'Elche': ['IES Elche 1'],
    'Denia': ['IES Denia 1'],
  };

  final List<String> _tiposAules = ['Semi', 'Presencial', 'ESO', 'Bachillerato'];

  // ===== Valores seleccionados =====
  String? _selectedProvincia;
  String? _selectedPoble;
  String? _selectedInstitut;
  String? _selectedTipo;

  // ===== Credenciales =====
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // ===== Función de envío =====
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedProvincia == null ||
        _selectedPoble == null ||
        _selectedInstitut == null ||
        _selectedTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final aulesService = AulesService();

      await aulesService.setAulesData(
        provincia: _selectedProvincia!,
        poble: _selectedPoble!,
        institut: _selectedInstitut!,
        tipo: _selectedTipo!,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta de Aules registrada correctamente')),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pueblos = _selectedProvincia != null ? _pueblos[_selectedProvincia!] ?? [] : [];
    final instituts = _selectedPoble != null ? _instituts[_selectedPoble!] ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar cuenta Aules'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== Provincia =====
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Provincia',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedProvincia,
                items: _provincias.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedProvincia = v;
                    _selectedPoble = null;
                    _selectedInstitut = null;
                  });
                },
                validator: (v) => v == null ? 'Selecciona una provincia' : null,
              ),
              const SizedBox(height: 16),

              /// Poble
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Población',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedPoble,
                items: pueblos
                    .map<DropdownMenuItem<String>>(
                        (p) => DropdownMenuItem<String>(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedPoble = v;
                    _selectedInstitut = null;
                  });
                },
                validator: (v) => v == null ? 'Selecciona un pueblo' : null,
              ),
              const SizedBox(height: 16),
              /// Institut
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Instituto',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedInstitut,
                items: instituts
                    .map<DropdownMenuItem<String>>(
                        (i) => DropdownMenuItem<String>(value: i, child: Text(i)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedInstitut = v);
                },
                validator: (v) => v == null ? 'Selecciona un instituto' : null,
              ),
              const SizedBox(height: 16),

              // ===== Tipo de Aules =====
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Aules',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedTipo,
                items: _tiposAules.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedTipo = v),
                validator: (v) => v == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),

              // ===== Credenciales =====
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario Aules',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Introduce el usuario' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Aules',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Introduce la contraseña' : null,
              ),
              const SizedBox(height: 24),

              // ===== Botón =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Registrar Aules'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}