import 'dart:convert';
import 'package:http/http.dart' as http;

class AulesWebService {
  static const String _baseUrl = 'http://localhost:3001';

  // ===== LOGIN AULES =====
  static Future<void> login({
    required String nia,
    required String password,
    required String modalidad,
    required String provincia,
  }) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nia': nia,
        'password': password,
        'modalidad': modalidad.toLowerCase(),
        'provincia': provincia,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error login Aules (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===== DESCARGAR PDFs =====
  static Future<void> downloadPdfs({
    required String instituto,
    required String modalidad,
    required String provincia,
  }) async {
    final url = Uri.parse('$_baseUrl/download-pdfs');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'instituto': instituto,
        'modalidad': modalidad.toLowerCase(),
        'provincia': provincia,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error descarga PDFs (${response.statusCode}): ${response.body}',
      );
    }
  }
}