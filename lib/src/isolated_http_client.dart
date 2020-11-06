import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:isolated_http_client/src/utils.dart';
import 'package:meta/meta.dart';
import 'package:worker_manager/worker_manager.dart';

import 'exceptions.dart';

abstract class HttpClient {
  factory HttpClient(
          {Duration timeout = const Duration(seconds: 10), bool log = false}) =>
      IsolatedHttpClient(timeout: timeout, log: log);

  Cancelable<Response> get({
    @required String host,
    String path,
    Map<String, String> query,
    Map<String, String> headers,
  });

  Cancelable<Response> post({
    @required String host,
    String path,
    Map<String, String> query,
    Map<String, String> headers,
    Object body,
  });
}

class IsolatedHttpClient implements HttpClient {
  final Duration timeout;
  final bool log;

  IsolatedHttpClient({this.timeout, this.log});

  Response _checkedResponse(Response response, RequestBundle requestBundle) {
    final statusCode = response.statusCode;
    if (statusCode >= 200 && statusCode < 300) return response;
    if (statusCode == 401) {
      throw HttpUnauthorizedException(response.body, requestBundle);
    }
    if (statusCode >= 400 && statusCode < 500) {
      throw HttpClientException(response.body, requestBundle);
    }
    if (statusCode >= 500 && statusCode < 600) {
      throw HttpServerException(response.body, requestBundle);
    }
    throw HttpUnknownException(response.body, requestBundle);
  }

  static Future<Response> _get(
    RequestBundle bundle,
  ) async {
    final url = bundle.url;
    final headers = bundle.headers;
    final timeout = bundle.timeout;
    final httpResponse =
        await http.get(Uri.encodeFull(url), headers: headers).timeout(timeout);
    final isolatedResponse = Response(
        httpResponse.body.isNotEmpty
            ? jsonDecode(httpResponse.body) as Map<String, dynamic>
            : <String, dynamic>{},
        httpResponse.statusCode,
        httpResponse.headers);
    return isolatedResponse;
  }

  @override
  Cancelable<Response> get(
      {@required String host,
      String path = '',
      Map<String, String> query,
      Map<String, String> headers}) {
    final queryString = makeQuery(query);
    final fullPath = '$host$path$queryString';
    if (log) {
      print('path: $fullPath,\nheaders: $headers');
    }
    final getBundle = RequestBundle(fullPath, query, headers, timeout, null);
    return Executor().execute(arg1: getBundle, fun1: _get).next(
        onValue: (value) {
      if (log) print(value.log());
      return _checkedResponse(value, getBundle);
    });
  }

  static Future<Response> _post(
    RequestBundle bundle,
  ) async {
    final url = bundle.url;
    final headers = bundle.headers;
    final timeout = bundle.timeout;
    final body = bundle.body;
    final httpResponse = await http
        .post(Uri.encodeFull(url), headers: headers, body: body)
        .timeout(timeout);
    final isolatedResponse = Response(
        httpResponse.body.isNotEmpty
            ? jsonDecode(httpResponse.body) as Map<String, dynamic>
            : <String, dynamic>{},
        httpResponse.statusCode,
        httpResponse.headers);
    return isolatedResponse;
  }

  @override
  Cancelable<Response> post(
      {@required String host,
      String path = '',
      Map<String, String> query,
      Map<String, String> headers,
      @required Object body}) {
    final queryString = makeQuery(query);
    final fullPath = '$host$path$queryString';
    if (log) print('path: $fullPath,\nheaders: $headers, \nbody: $body');
    final postBundle = RequestBundle(fullPath, query, headers, timeout, body);
    return Executor().execute(arg1: postBundle, fun1: _post).next(
        onValue: (value) {
      if (log) print(value.log());
      return _checkedResponse(value, postBundle);
    });
  }
}

class RequestBundle {
  final String url;
  final Map<String, String> query;
  final Map<String, String> headers;
  final Duration timeout;
  final Object body;

  RequestBundle(String url, Map<String, String> query,
      Map<String, String> headers, Duration timeout, this.body)
      : url = url ?? '',
        query = query ?? <String, String>{},
        timeout = timeout ?? const Duration(seconds: 5),
        headers = headers ?? <String, String>{};

  @override
  String toString() {
    return 'url : $url\nquery: $query\nheaders: $headers\ntimeout: $timeout\n body: $body';
  }
}

class Response {
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final int statusCode;

  Response(this.body, this.statusCode, this.headers);

  @override
  String toString() {
    return 'statusCode : $statusCode\nheaders: $headers\n body: $body';
  }
}
