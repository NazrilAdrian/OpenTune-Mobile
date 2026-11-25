int requiredInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is num && value == value.toInt()) return value.toInt();
  throw FormatException(
      'Kolom "$field" wajib berisi bilangan bulat; diterima: $value.');
}

DateTime requiredTimestamp(Map<String, dynamic> json, String field) =>
    _timestamp(json[field], field);

DateTime? optionalDate(Map<String, dynamic> json, String field) {
  final value = json[field];
  return value == null ? null : _timestamp(value, field);
}

DateTime _timestamp(dynamic value, String field) {
  if (value is String) {
    try {
      return DateTime.parse(value);
    } on FormatException {
      throw FormatException('Kolom tanggal "$field" tidak valid: "$value".');
    }
  }
  throw FormatException(
      'Kolom tanggal "$field" wajib berupa string; diterima: $value.');
}
