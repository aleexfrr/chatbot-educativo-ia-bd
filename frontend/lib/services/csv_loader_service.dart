import 'package:flutter/services.dart';
import '../models/instituto_data.dart';
import 'package:csv/csv.dart';

class CsvLoaderService {
  static List<InstitutoData>? _cachedData;

  /// Carga y parsea el archivo CSV
  static Future<List<InstitutoData>> loadInstitutos() async {
    // Si ya está en caché, devolverlo
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      // Cargar el archivo CSV desde assets
      final rawData = await rootBundle.loadString('assets/data/centros-docentes-cleaned-final.csv');

      // Parsear el CSV
      final List<List<dynamic>> csvTable = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(rawData);

      // Saltar la primera fila (headers)
      final dataRows = csvTable.skip(1);

      // Convertir cada fila en InstitutoData
      _cachedData = dataRows
          .map((row) => InstitutoData.fromCsvRow(row))
          .where((instituto) => instituto.nombreCompleto.isNotEmpty)
          .toList();

      print('✅ CSV cargado: ${_cachedData!.length} institutos');
      return _cachedData!;
      
    } catch (e) {
      print('❌ Error cargando CSV: $e');
      rethrow;
    }
  }

  /// Obtiene lista única de provincias
  static Future<List<String>> getProvincias() async {
    final institutos = await loadInstitutos();
    final provincias = institutos
        .map((i) => i.provincia)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    provincias.sort();
    return provincias;
  }

  /// Obtiene localidades de una provincia específica
  static Future<List<String>> getLocalidades(String provincia) async {
    final institutos = await loadInstitutos();
    final localidades = institutos
        .where((i) => i.provincia == provincia)
        .map((i) => i.localidad)
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList();
    localidades.sort();
    return localidades;
  }

  /// Obtiene institutos de una localidad específica
  static Future<List<String>> getInstitutos(String localidad) async {
    final institutos = await loadInstitutos();
    final nombresInstitutos = institutos
        .where((i) => i.localidad == localidad)
        .map((i) => i.nombreCompleto)
        .where((n) => n.isNotEmpty)
        .toList();
    nombresInstitutos.sort();
    return nombresInstitutos;
  }

  /// Obtiene el objeto completo de un instituto por su nombre
  static Future<InstitutoData?> getInstitutoByName(String nombre) async {
    final institutos = await loadInstitutos();
    try {
      return institutos.firstWhere((i) => i.nombreCompleto == nombre);
    } catch (e) {
      return null;
    }
  }
}