import 'dart:io' show Platform;
import 'package:isolated_http_client/isolated_http_client.dart';
import 'package:worker_manager/worker_manager.dart';

final client = HttpClient(log: true);

void main() async {
  await Executor().warmUp(log: true);

  print('-' * 100);
  await get();
  print('-' * 100);
  await head();
  print('-' * 100);
  await patch();
  print('-' * 100);
  await post();
  print('-' * 100);
  await put();
  print('-' * 100);
  await delete();
  print('-' * 100);
  print('-' * 100);
  await postRequest();
  print('-' * 100);
  print('-' * 100);
  await multipartPostRequest();
  print('-' * 100);
}

Future<void> get() async {
  final r =
      await client.get(host: 'https://httpbin.org/get?foo1=bar1&foo2=bar2');
  print(r.body);
}

Future<void> head() async {
  final r = await client.head(host: 'https://httpbin.org/get');
  print(r.body);
}

Future<void> patch() async {
  final r = await client
      .patch(host: 'https://httpbin.org/patch', body: {'data': 123});
  print(r.body);
}

Future<void> post() async {
  final r =
      await client.post(host: 'https://httpbin.org/post', body: {'data': 123});
  print(r.body);
}

Future<void> put() async {
  final r =
      await client.put(host: 'https://httpbin.org/put', body: {'data': 123});
  print(r.body);
}

Future<void> delete() async {
  final r = await client
      .delete(host: 'https://httpbin.org/delete', body: {'data': 123});
  print(r.body);
}

Future<void> postRequest() async {
  final r = await client.request(
    bundle: RequestBundleWithBody(
      HttpMethod.post,
      'https://httpbin.org/post',
      {},
      {},
      body: {'data': 123},
    ),
  );
  print(r.body);
}

Future<void> multipartPostRequest() async {
  final scriptFolder = Platform.script.pathSegments
      .take(Platform.script.pathSegments.length - 1)
      .join('/');
  final r = await client.request(
    bundle: MultipartRequestBundle(
      HttpMethod.post,
      'https://httpbin.org/post',
      {},
      {},
      files: [MultipartBundleFile.fromPath('image', '/$scriptFolder/cat.jpeg')],
    ),
  );
  print(r.body);
}
