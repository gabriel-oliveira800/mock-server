import 'dart:convert';

import 'package:shelf/shelf.dart';

class RouterIntercept {
  RouterIntercept._();
  factory RouterIntercept() => _instance;
  static final RouterIntercept _instance = RouterIntercept._();

  static Future<Response> intercept(Request request) async {
    return Response.ok(json.encode({
      'message': 'Route not found',
      'status': 404,
      'posts': [
        {
          'id': 1,
          'title': 'Post 1',
          'content': 'Content 1',
        },
        {
          'id': 2,
          'title': 'Post 2',
          'content': 'Content 2',
        },
      ],
    }));
  }
}

class _RouteNotFoundResponse extends Response {
  static const _message = 'Route not found';
  static final _messageBytes = utf8.encode(_message);

  _RouteNotFoundResponse() : super.notFound(_message);

  @override
  Stream<List<int>> read() => Stream<List<int>>.value(_messageBytes);

  @override
  Response change({
    Map<String, /* String | List<String> */ Object?>? headers,
    Map<String, Object?>? context,
    Object? body,
  }) {
    return super.change(
      headers: headers,
      context: context,
      body: body ?? _message,
    );
  }
}
