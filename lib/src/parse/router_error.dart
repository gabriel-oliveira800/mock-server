class RouterError implements Exception {
  final int statusCode;
  final String message;
  const RouterError(this.statusCode, this.message);

  factory RouterError.fromJson(dynamic error) {
    if (error is String) return RouterError(500, error);
    return RouterError(error['statusCode'] ?? 500, error['message']);
  }

  @override
  String toString() {
    return 'RouterData(statusCode: $statusCode, message: $message)';
  }
}
