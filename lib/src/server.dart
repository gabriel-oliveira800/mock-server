import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';

import 'middleware/log_requests.dart';
import 'middleware/router_intercept.dart';
import 'parse/router_parse.dart';

class MockServer {
  MockServer._();
  factory MockServer() => _instance;
  static final MockServer _instance = MockServer._();

  final app = Router();
  final pipeline = const Pipeline()..addMiddleware(LogRequests.log);

  late final HttpServer _server;

  void configure({String? path, File? file}) {
    // final routes = RouterParse.of(path: path, file: file).getRoutes();

    // for (final route in routes) {
    //   app.add(route.method, route.path, (Request request) async {
    //     await Future.delayed(route.timeout);

    //     if (route.error != null) {
    //       return Response(
    //         body: route.error?.message,
    //         route.error?.statusCode ?? 500,
    //         // headers: Map.from(route.headers?.data ?? {}),
    //       );
    //     }

    //     if (route.headers?.hasErrorSimulated() ?? false) {
    //       return Response(
    //         route.headers?.statusCode ?? 500,
    //         // headers: Map.from(route.headers?.data ?? {}),
    //         body: route.headers?.errorResponse ?? route.response,
    //       );
    //     }

    //     return Response(
    //       route.statusCode,
    //       body: route.response,
    //       // headers: Map.from(route.headers?.data ?? {}),
    //     );
    //   });
    // }
  }

  Future<void> start({int port = 8080, String? path, File? file}) async {
    // configure(path: path, file: file);

    final handler = pipeline.addHandler(RouterIntercept.intercept);
    _server = await io.serve(handler, 'localhost', port);
    LogRequests.warning('Server started on http://localhost:$port');
  }

  Future<void> stop() async {
    await _server.close(force: true);
    LogRequests.debug('Server stopped');
  }
}
