class HttpClientException implements Exception {
  final Map<String, dynamic> message;

  HttpClientException(this.message);

  @override
  String toString() => "HttpClientException: ${(message ?? '').toString()}";
}

class HttpUnauthorizedException implements Exception {
  final Map<String, dynamic> message;

  HttpUnauthorizedException(this.message);
  @override
  String toString() =>
      "HttpUnauthorizedException: ${(message ?? '').toString()}";
}

class HttpServerException implements Exception {
  final Map<String, dynamic> message;

  HttpServerException(this.message);
  @override
  String toString() => "HttpServerException: ${(message ?? '').toString()}";
}

class HttpUnknownException implements Exception {
  final Map<String, dynamic> message;

  HttpUnknownException(this.message);
  @override
  String toString() => "HttpUnknownException: ${(message ?? '').toString()}";
}
