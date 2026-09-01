import 'package:flutter_test/flutter_test.dart';

import 'package:dart_multithreading/isolate.dart' as app;

void main() {
  test('isolate demo', () async {
    await app.main();
  });
}