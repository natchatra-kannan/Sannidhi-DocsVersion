import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sannidhi/main.dart';
import 'package:sannidhi/core/router.dart';
import 'package:sannidhi/services/storage_service.dart';

void main() {
  setUp(() async {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('SannidhiApp navigation and build test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SannidhiApp(),
      ),
    );

    // Initial route is /login
    expect(find.byType(SannidhiApp), findsOneWidget);
    await tester.pumpAndSettle();

    // Directly navigate to / to test home screen build
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('S.NIDHI Culture Feed'), findsOneWidget);

    // Navigate to /veedu
    router.go('/veedu');
    await tester.pumpAndSettle();

    // Navigate to /makkal
    router.go('/makkal');
    await tester.pumpAndSettle();

    // Navigate to /booking
    router.go('/booking');
    await tester.pumpAndSettle();

    // Navigate to /awards
    router.go('/awards');
    await tester.pumpAndSettle();

    // Navigate to /punch
    router.go('/punch');
    await tester.pumpAndSettle();
    expect(find.text('Punchu Attendance'), findsOneWidget);

    // Navigate to /profile
    router.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('My SANNIDHI Profile'), findsOneWidget);
  });
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(MockHttpClientResponse());
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  static final List<int> _imageBytes = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
  ];

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _imageBytes.length;

  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #listen) {
      final callback = invocation.positionalArguments[0] as void Function(List<int>)?;
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      final onError = invocation.namedArguments[#onError] as Function?;
      
      return Stream<List<int>>.fromIterable([_imageBytes]).listen(
        callback,
        onError: onError,
        onDone: onDone,
      );
    }
    return null;
  }
}
