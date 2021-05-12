import 'requests.dart';

class HttpClientException implements Exception {
  final Map<String, dynamic>? message;
  final BaseRequestBundle? requestBundle;

  HttpClientException(this.message, this.requestBundle);

  @override
  String toString() =>
      "HttpClientException: ${(message ?? '').toString()}\n Request: ${requestBundle.toString()}";
}

class HttpUnauthorizedException implements Exception {
  final Map<String, dynamic>? message;
  final BaseRequestBundle? requestBundle;

  HttpUnauthorizedException(this.message, this.requestBundle);
  @override
  String toString() =>
      "HttpUnauthorizedException: ${(message ?? '').toString()}\n Request: ${requestBundle?.toString()}";
}

class HttpServerException implements Exception {
  final Map<String, dynamic>? message;
  final BaseRequestBundle? requestBundle;

  HttpServerException(this.message, this.requestBundle);
  @override
  String toString() =>
      "HttpServerException: ${(message ?? '').toString()}\n Request: ${requestBundle.toString()}";
}

class HttpUnknownException implements Exception {
  final Map<String, dynamic>? message;
  final BaseRequestBundle? requestBundle;

  HttpUnknownException(this.message, this.requestBundle);
  @override
  String toString() =>
      "HttpUnknownException: ${(message ?? '').toString()}\n Request: ${requestBundle.toString()}";
}
