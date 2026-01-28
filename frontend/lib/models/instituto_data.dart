class InstitutoData {
  final String denominacionGenericaEs;
  final String denominacionEspecifica;
  final String localidad;
  final String provincia;
  final String titular;
  final String denominacionGenericaVal;
  final String denominacion;
  final String tipoVia;

  InstitutoData({
    required this.denominacionGenericaEs,
    required this.denominacionEspecifica,
    required this.localidad,
    required this.provincia,
    required this.titular,
    required this.denominacionGenericaVal,
    required this.denominacion,
    required this.tipoVia,
  });

  factory InstitutoData.fromCsvRow(List<dynamic> row) {
    return InstitutoData(
      denominacionGenericaEs: row[0]?.toString().trim() ?? '',
      denominacionEspecifica: row[1]?.toString().trim() ?? '',
      localidad: row[2]?.toString().trim() ?? '',
      provincia: row[3]?.toString().trim() ?? '',
      titular: row[4]?.toString().trim() ?? '',
      denominacionGenericaVal: row[5]?.toString().trim() ?? '',
      denominacion: row[6]?.toString().trim() ?? '',
      tipoVia: row[7]?.toString().trim() ?? '',
    );
  }

  String get nombreCompleto => denominacionEspecifica.isNotEmpty
      ? denominacionEspecifica
      : denominacionGenericaEs;
}