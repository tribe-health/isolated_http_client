import 'package:isolated_http_client/isolated_http_client.dart';
import 'package:worker_manager/worker_manager.dart';

// ignore: avoid_void_async
void main() async {
  await Executor().warmUp();
  final client = HttpClient(log: true);
  final r = await client.get(
      host: 'https://postman-echo.com/get?foo1=bar1&foo2=bar2');
  print(r.body);
  final r2 = await client
      .post(host: 'https://postman-echo.com/post', body: {'data': 123});
  print(r2.body);
}
