import 'dart:convert';
import 'package:http/http.dart' as http;

class AgentWebService {
  static final String _baseUrl = "http://localhost:3001/chat";

  static Future<String> obtenerRespuestaAgente(String message) async {
    final url = Uri.parse('$_baseUrl?msg=$message');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['respuesta'] as String;
    } else {
      throw Exception('Error al obtener la respuesta: ${response.statusCode}');
    }
  }
}