import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:checks/checks.dart';

import 'package:mock_server/src/parse/router_parse.dart';

void main() {
  const String path = 'test/data/routes.json';

  group('RouterParse.of', () {
    test('should ArgumentError when json is invalid', () {
      final parse = RouterParse.of(path: 'test/data/invalid.json');
      expect(() => parse.getRoutes(), throwsA(isA<ArgumentError>()));
    });

    test('should return ArgumentError when path is null', () {
      expect(() => RouterParse.of(path: null), throwsA(isA<ArgumentError>()));
    });

    test('should return ArgumentError when file is null', () {
      expect(() => RouterParse.of(file: null), throwsA(isA<ArgumentError>()));
    });

    test('should return RouterParse when path is not null', () {
      final parse = RouterParse.of(path: path);

      check(parse).isA<RouterParse>();
      check(parse.jsonRoutesFile.path).equals(path);
    });

    test('should return RouterParse when file is not null', () {
      final parse = RouterParse.of(file: File(path));

      check(parse).isA<RouterParse>();
      check(parse.jsonRoutesFile.path).equals(path);
    });
  });

  group('RouterParse.getRoutes', () {
    final routes = RouterParse.of(path: path).getRoutes();
    check(routes).isNotEmpty();
    check(routes.length).equals(4);

    test('should create parse with "GET-POST" key', () {
      final router = routes.first;

      check(router.key).equals('get-posts');
      check(router.path).equals('/posts/');
      check(router.method).equals('GET');
      check(router.response as List).deepEquals([
        {"id": "1", "title": "a title"},
        {"id": "2", "title": "another title"}
      ]);
      check(router.body).isNull();
      check(router.statusCode).equals(200);
      check(router.error).isNull();
      check(router.timeout).equals(const Duration(milliseconds: 1000));
    });

    test('should create parser with "GET-POSTS-WITH-ERROR" key', () {
      final router = routes[1];

      check(router.key).equals('get-posts-with-error');
      check(router.path).equals('/posts/');
      check(router.method).equals('GET');
      check(router.response).isNull();
      check(router.body).isNull();
      check(router.statusCode).equals(500);
      check(router.error).isNotNull();
      check(router.error!.statusCode).equals(500);
      check(router.error!.message).equals('Internal server error');
    });

    test('should create parser with "GET-POSTS-WITH-ERROR-IN-HEADERS" key', () {
      final router = routes[2];

      check(router.key).equals('get-posts-with-error-in-headers');
      check(router.path).equals('/posts/');
      check(router.method).equals('GET');
      check(router.response).isNull();
      check(router.body).isNull();
      check(router.statusCode).equals(1234);
      check(router.error).isNull();
    });

    test(
        'should create parser with "GET-POSTS-WITH-ERROR-IN-HEADERS-BOOLEAN" key',
        () {
      final router = routes.last;

      check(router.key).equals('get-posts-with-error-in-headers-boolean');
      check(router.path).equals('/posts/');
      check(router.method).equals('GET');
      check(router.response).isNull();
      check(router.body).isNull();
      check(router.statusCode).equals(500);
      check(router.error).isNull();
    });
  });
}
