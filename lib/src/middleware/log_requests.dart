import 'dart:async';

import 'package:talker_logger/talker_logger.dart';
import 'package:shelf/shelf.dart';

abstract class LogRequests {
  static final _logger = TalkerLogger();
  static Middleware get log => _log;

  static void debug(String message) => _logger.debug(message);
  static void warning(String message) => _logger.warning(message);
  static void error(String message) => _logger.error(message);

  static Handler _log(Handler innerHandler) {
    return (request) {
      final startTime = DateTime.now().toIso8601String();
      final watch = Stopwatch()..start();

      return Future.sync(() => innerHandler(request)).then((response) {
        _logger.info(
          '[$startTime] ${request.method} ${request.requestedUri} -> ${response.statusCode} ${watch.elapsed.inMilliseconds}ms',
        );

        return response;
      }, onError: (Object error, StackTrace stackTrace) {
        if (error is HijackException) throw error;

        _logger.info(
          '[$startTime] ${request.method} ${request.requestedUri} -> $error ${watch.elapsed.inMilliseconds}ms',
        );

        throw error;
      });
    };
  }
}
