import 'router_error.dart';

typedef RawData = Map<String, dynamic>;

class RouterHeaders {
  final RawData data;
  const RouterHeaders(this.data);

  static const String xErrorSimulated = 'x-error-simulated';

  static RawData get defaultHeaders => {
        'content-type': 'application/json',
        'x-powered-by': 'mock-server',
      };

  factory RouterHeaders.fromJson(RawData? headers) {
    if (headers == null) return RouterHeaders(defaultHeaders);
    return RouterHeaders({...defaultHeaders, ...headers});
  }

  bool hasErrorSimulated() {
    const key = RouterHeaders.xErrorSimulated;
    return data.containsKey(key) && data[key] != null;
  }

  int? get statusCode {
    if (!hasErrorSimulated()) return null;

    final value = data[RouterHeaders.xErrorSimulated];
    if (value is bool) return 500;
    return (value as RawData)['status'] ?? 500;
  }

  dynamic get errorResponse {
    if (!hasErrorSimulated()) return null;

    final value = data[RouterHeaders.xErrorSimulated];
    if (value is bool) return 'Internal server error';
    return (value as RawData)['message'] ?? 'Internal server error';
  }

  @override
  String toString() => 'RouterHeaders(data: $data)';
}

class RouterData {
  final String key;
  final String path;
  final String method;
  final dynamic response;
  final dynamic body;
  final RouterError? error;
  final int statusCode;
  final Duration timeout;

  final RawData? query;
  final RouterHeaders? headers;

  const RouterData({
    this.error,
    this.query,
    this.headers,
    required this.key,
    required this.path,
    this.response = '',
    this.body = '',
    required this.method,
    this.statusCode = 200,
    this.timeout = const Duration(seconds: 5),
  });

  factory RouterData.fromJson(String key, RawData json) {
    if (!_ensureHasKeyPathAndMethod(key, json)) {
      throw ArgumentError('Key, path and method are required');
    }

    final rawError = json['error'];
    final error = rawError != null ? RouterError.fromJson(rawError) : null;

    final rawHeaders = RouterHeaders.fromJson(json['headers']);
    final statusByHeader = rawHeaders.statusCode;

    final rawTimeout = json['timeout'];
    final timeout = rawTimeout != null
        ? Duration(milliseconds: rawTimeout as int)
        : const Duration(seconds: 5);

    return RouterData(
      key: key,
      error: error,
      timeout: timeout,
      body: json['body'],
      headers: rawHeaders,
      query: json['query'],
      method: json['method'],
      response: json['response'],
      path: _formatPath(json['path']),
      statusCode: statusByHeader ?? error?.statusCode ?? json['status'] ?? 200,
    );
  }

  static String _formatPath(String path) {
    if (!path.startsWith('/')) return '/$path';
    return path;
  }

  static bool _ensureHasKeyPathAndMethod(String key, RawData data) {
    bool hasData(dynamic a) => a is String && a.isNotEmpty;

    return key.isNotEmpty &&
        data.containsKey('path') &&
        hasData(data['path']) &&
        data.containsKey('method') &&
        hasData(data['method']);
  }

  @override
  String toString() {
    return 'RouterData(key: $key, method: $method, path: $path, response: $response, body: $body error: $error, statusCode: $statusCode, query: $query, headers: $headers)';
  }
}
