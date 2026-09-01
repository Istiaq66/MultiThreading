import 'dart:isolate';

import 'package:flutter/foundation.dart';


/// Run using fvm flutter test test/isolate_test.dart
/// Used Future.delayed() only to keep the main() function alive long enough for the spawned/background isolate to finish and print its result.

Future<void> main() async {
  // ============================================================
  // 1. NORMAL FUNCTION
  // ============================================================

  print('\n========== NORMAL FUNCTION ==========');
  print('Before task triggered');

  processDataNormal(100000000);

  print('After task triggered');


  // ============================================================
  // 2. ISOLATE.SPAWN()
  // ============================================================

  print('\n========== ISOLATE.SPAWN() ==========');
  print('Before task triggered');

  final receivePort = ReceivePort();

  await Isolate.spawn(
    processDataWithIsolate,
    [
      100000000,
      receivePort.sendPort,
    ],
  );

  receivePort.listen((message) {
    print(message);
    receivePort.close();
  });

  print('After task triggered');

  await Future.delayed(const Duration(seconds: 1));

  // ============================================================
  // 3. COMPUTE()
  // ============================================================

  print('\n========== COMPUTE() ==========');
  print('Before task triggered');

  compute(
    processDataWithCompute,
    100000000,
  ).then((message) {
    print(message);
  });

  print('After task triggered');

  await Future.delayed(const Duration(seconds: 1));
}


// ================================================================
// 1. NORMAL FUNCTION
// ================================================================

void processDataNormal(int count) {
  for (int i = 0; i < count; i++) {
    // Heavy processing
  }

  print('Data Processing Done - Normal');
}


// ================================================================
// 2. ISOLATE.SPAWN()
// ================================================================

void processDataWithIsolate(List<Object> args) {
  final count = args[0] as int;
  final sendPort = args[1] as SendPort;

  for (int i = 0; i < count; i++) {
    // Heavy processing
  }

  sendPort.send('Data Processing Done - Isolate');
}


// ================================================================
// 3. COMPUTE()
// ================================================================

String processDataWithCompute(int count) {
  for (int i = 0; i < count; i++) {
    // Heavy processing
  }

  return 'Data Processing Done - Compute';
}