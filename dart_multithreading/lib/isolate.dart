import 'dart:isolate';

import 'package:flutter/foundation.dart';


/// Run using 'fvm flutter test test/isolate_test.dart'
/// Used Future.delayed() only to keep the main() function alive long enough for the spawned/background isolate to finish and debugPrint its result.

Future<void> main() async {
  // ============================================================
  // 1. NORMAL FUNCTION
  // ============================================================

  debugPrint('\n========== NORMAL FUNCTION ==========');
  debugPrint('Before task triggered');

  processDataNormal(100000000);

  debugPrint('After task triggered');


  // ============================================================
  // 2. ISOLATE.SPAWN()
  // ============================================================

  debugPrint('\n========== ISOLATE.SPAWN() ==========');
  debugPrint('Before task triggered');

  final receivePort = ReceivePort();

  await Isolate.spawn(
    processDataWithIsolate,
    [
      100000000,
      receivePort.sendPort,
    ],
  );

  receivePort.listen((message) {
    debugPrint(message);
    receivePort.close();
  });

  debugPrint('After task triggered');

  await Future.delayed(const Duration(seconds: 1));

  // ============================================================
  // 3. COMPUTE()
  // ============================================================

  debugPrint('\n========== COMPUTE() ==========');
  debugPrint('Before task triggered');

  compute(
    processDataWithCompute,
    100000000,
  ).then((message) {
    debugPrint(message);
  });

  debugPrint('After task triggered');

  await Future.delayed(const Duration(seconds: 1));
}


// ================================================================
// 1. NORMAL FUNCTION
// ================================================================

void processDataNormal(int count) {
  for (int i = 0; i < count; i++) {
    // Heavy processing
  }

  debugPrint('Data Processing Done - Normal');
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