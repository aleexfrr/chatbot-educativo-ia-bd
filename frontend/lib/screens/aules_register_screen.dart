import 'package:flutter/material.dart';
import '../services/aules_service.dart';
import '../services/csv_loader_service.dart';

class AulesRegisterScreen extends StatefulWidget {
  const AulesRegisterScreen({super.key});

  @override
  State<AulesRegisterScreen> createState() => _AulesRegisterScreenState();
}

class _AulesRegisterScreenState extends State<AulesRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ===== Listas dinámicas cargadas desde CSV =====
  List<String> _provincias = [];
  List<String> _localidades = [];
  List<String> _institutos = [];

  // ===== Lista estática de tipos =====
  final List<String> _tiposAules = ['Semipresencial', 'Presencial', 'ESO', 'Bachillerato'];

  // ===== Valores seleccionados =====
  String? _selectedProvincia;
  String? _selectedLocalidad;
  String? _selectedInstituto;
  String? _selectedTipo;

  // ===== Credenciales =====
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  final bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProvincias();
  }

  // ===== Cargar provincias desde CSV =====
  Future<void> _loadProvincias() async {
    try {
      final provincias = await CsvLoaderService.getProvincias();
      setState(() {
        _provincias = provincias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando provincias: $e')),
      );
    }
  }

  // ===== Cargar localidades cuando se selecciona provincia =====
  Future<void> _loadLocalidades(String provincia) async {
    setState(() => _isLoading = true);
    try {
      final localidades = await CsvLoaderService.getLocalidades(provincia);
      setState(() {
        _localidades = localidades;
        _selectedLocalidad = null;
        _selectedInstituto = null;
        _institutos = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando localidades: $e')),
      );
    }
  }

  // ===== Cargar institutos cuando se selecciona localidad =====
  Future<void> _loadInstitutos(String localidad) async {
    setState(() => _isLoading = true);
    try {
      final institutos = await CsvLoaderService.getInstitutos(localidad);
      setState(() {
        _institutos = institutos;
        _selectedInstituto = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando institutos: $e')),
      );
    }
  }

  // ===== Función de envío =====
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedProvincia == null ||
        _selectedLocalidad == null ||
        _selectedInstituto == null ||
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
        poble: _selectedLocalidad!,
        institut: _selectedInstituto!,
        tipo: _selectedTipo!,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Descarga de PDFs
      aulesService.ensurePdfsAvailable();

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
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      initialValue: _selectedProvincia,
                      items: _provincias
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedProvincia = v);
                          _loadLocalidades(v);
                        }
                      },
                      validator: (v) => v == null ? 'Selecciona una provincia' : null,
                    ),
                    const SizedBox(height: 16),

                    // ===== Localidad =====
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Población',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      initialValue: _selectedLocalidad,
                      items: _localidades
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: _selectedProvincia == null
                          ? null
                          : (v) {
                              if (v != null) {
                                setState(() => _selectedLocalidad = v);
                                _loadInstitutos(v);
                              }
                            },
                      validator: (v) => v == null ? 'Selecciona una población' : null,
                    ),
                    const SizedBox(height: 16),

                    // ===== Instituto =====
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Instituto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      initialValue: _selectedInstituto,
                      items: _institutos
                          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      onChanged: _selectedLocalidad == null
                          ? null
                          : (v) => setState(() => _selectedInstituto = v),
                      validator: (v) => v == null ? 'Selecciona un instituto' : null,
                    ),
                    const SizedBox(height: 16),

                    // ===== Tipo de Aules =====
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Aules',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      initialValue: _selectedTipo,
                      items: _tiposAules
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
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
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Introduce el usuario' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña Aules',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Introduce la contraseña' : null,
                    ),
                    const SizedBox(height: 24),

                    // ===== Botón =====
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Registrar Aules'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}