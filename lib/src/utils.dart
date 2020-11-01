import '../isolated_http_client.dart';

String bearer(String token) => 'bearer $token';

extension Log on Response {
  String log() {
    return 'headers: $headers\nstatusCode: $statusCode\nbody: $body';
  }
}

String makeQuery(Map<String, String> queryParameters) {
  if (queryParameters == null || queryParameters.isEmpty) {
    return '';
  }
  final result = StringBuffer('?');
  var separator = '';
  void writeParameter(String key, String value) {
    result.write(separator);
    separator = '&';
    result.write(key);
    if (value != null && value.isNotEmpty) {
      result.write('=');
      result.write(value);
    }
  }

  queryParameters.forEach((key, value) {
    if (value != null) {
      writeParameter(key, value);
    }
  });
  return result.toString();
}
