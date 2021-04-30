import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:isolated_http_client/src/utils.dart';
import 'package:worker_manager/worker_manager.dart';

import 'exceptions.dart';

abstract class HttpClient {
  factory HttpClient(
          {Duration timeout = const Duration(seconds: 10), bool log = false}) =>
      IsolatedHttpClient(timeout, log);

  Cancelable<Response> get({
    required String host,
    String path,
    Map<String, String> query,
    Map<String, String> headers,
    bool fakeIsolate = false,
  });

  Cancelable<Response> post({
    required String host,
    String path,
    Map<String, String> query,
    Map<String, String> headers,
    Map<String, Object> body = const <String, Object>{},
    bool fakeIsolate = false,
  });
}

class IsolatedHttpClient implements HttpClient {
  final Duration timeout;
  final bool log;

  IsolatedHttpClient(this.timeout, this.log);

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

  static Future<Response> _get(RequestBundle bundle, bool log) async {
    final url = bundle.url;
    final headers = bundle.headers;
    final timeout = bundle.timeout;
    final httpResponse =
        await http.get(Uri.parse(url), headers: headers).timeout(timeout);
    if (log) {
      print('path: $url,\nheaders: $headers');
    }
    try {
      final body = httpResponse.body.isNotEmpty
          ? jsonDecode(httpResponse.body) as Map<String, dynamic>
          : <String, dynamic>{};
      final isolatedResponse =
          Response(body, httpResponse.statusCode, httpResponse.headers);
      if (log) {
        print(isolatedResponse);
      }
      return isolatedResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Cancelable<Response> get({
    required String host,
    String path = '',
    Map<String, String> query = const <String, String>{},
    Map<String, String> headers = const <String, String>{},
    bool fakeIsolate = false,
  }) {
    final queryString = makeQuery(query);
    final fullPath = '$host$path$queryString';
    final getBundle = RequestBundle(fullPath, query, headers, timeout);
    if (fakeIsolate) {
      return Executor()
          .fakeExecute(arg1: getBundle, arg2: log, fun2: _get)
          .next(onValue: (value) {
        return _checkedResponse(value, getBundle);
      });
    }
    return Executor().execute(arg1: getBundle, arg2: log, fun2: _get).next(
        onValue: (value) {
      return _checkedResponse(value, getBundle);
    });
  }

  static Future<Response> _post(RequestBundle bundle, bool log) async {
    final url = bundle.url;
    final headers = bundle.headers;
    final timeout = bundle.timeout;
    try {
      final requestBody = bundle.body;
      final encodedBody =
          (requestBody.isEmpty) ? null : jsonEncode(requestBody);
      if (log) {
        print('path: $url,\nheaders: $headers, \nbody: $encodedBody');
      }
      final httpResponse = await http
          .post(Uri.parse(url), headers: headers, body: encodedBody)
          .timeout(timeout);
      final body = httpResponse.body.isNotEmpty
          ? jsonDecode(httpResponse.body) as Map<String, dynamic>
          : <String, dynamic>{};

      final isolatedResponse =
          Response(body, httpResponse.statusCode, httpResponse.headers);
      if (log) {
        print(isolatedResponse);
      }
      return isolatedResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Cancelable<Response> post({
    required String host,
    String path = '',
    Map<String, String> query = const <String, String>{},
    Map<String, String> headers = const <String, String>{},
    Map<String, Object> body = const <String, Object>{},
    bool fakeIsolate = false,
  }) {
    final queryString = makeQuery(query);
    final fullPath = '$host$path$queryString';
    final postBundle =
        RequestBundle(fullPath, query, headers, timeout, body: body);
    if (fakeIsolate) {
      return Executor()
          .fakeExecute(arg1: postBundle, arg2: log, fun2: _post)
          .next(onValue: (value) {
        return _checkedResponse(value, postBundle);
      });
    }
    return Executor().execute(arg1: postBundle, arg2: log, fun2: _post).next(
        onValue: (value) {
      return _checkedResponse(value, postBundle);
    });
  }
}

class RequestBundle {
  final String url;
  final Map<String, String> query;
  final Map<String, String> headers;
  final Duration timeout;
  final Map<String, Object> body;

  RequestBundle(String url, Map<String, String> query,
      Map<String, String> headers, Duration timeout,
      {this.body = const <String, Object>{}})
      : url = url,
        query = query,
        timeout = timeout,
        headers = headers;

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
