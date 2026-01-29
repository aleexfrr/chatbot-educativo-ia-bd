import 'dart:convert';
import 'package:http/http.dart' as http;

class AgentWebService {
  static final String _baseUrl = "http://localhost:3001/chat";

  /// Obtiene respuesta del agente de Bedrock
  /// 
  /// [message] - Mensaje del usuario
  /// [sessionId] - ID único de la conversación para mantener contexto
  static Future<String> obtenerRespuestaAgente(
    String message,
    String sessionId,
  ) async {
    try {
      // Construir URL con parámetros
      final url = Uri.parse(
        '$_baseUrl?msg=${Uri.encodeComponent(message)}&sessionId=${Uri.encodeComponent(sessionId)}'
      );

      print('🌐 Llamando a: $url');

      // Hacer petición GET
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30), // Timeout de 30 segundos
      );

      print('📡 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('respuesta')) {
          return data['respuesta'] as String;
        } else {
          throw Exception('Respuesta sin campo "respuesta"');
        }
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error de validación');
      } else if (response.statusCode == 500) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error del servidor');
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerRespuestaAgente: $e');
      rethrow;
    }
  }

  /// Verifica que el backend esté funcionando (opcional)
  static Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('http://localhost:3001/health');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend no disponible: $e');
      return false;
    }
  }
}