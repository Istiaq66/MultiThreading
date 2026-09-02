import 'dart:isolate';

import 'package:flutter/material.dart';

/// Run using 'fvm flutter test test/two_way_isolate_test.dart'

void main() async {
  debugPrint('Main Isolate: Starting...');

  // 1. Create a ReceivePort for the main isolate
  final mainReceivePort = ReceivePort();

  // 2. Spawn the worker isolate and pass the main isolate's SendPort
  final workerIsolate = await Isolate.spawn(
    workerTask,
    mainReceivePort.sendPort,
  );

  // 3. Listen for the worker isolate's SendPort and subsequent messages
  SendPort? workerSendPort;

  mainReceivePort.listen((message) {
    if (message is SendPort) {
      // The first message from the worker is always its SendPort
      workerSendPort = message;
      debugPrint('Main Isolate: Received Worker\'s SendPort. Handshake complete.');

      // 4. Send a command to the worker now that we have its port
      workerSendPort?.send('ProcessData:Item1');
    } else {
      // Handle regular computational data sent back from the worker
      debugPrint('Main Isolate received: $message');

      // Example of terminating the loop when a condition is met
      if (message == 'Task Complete') {
        mainReceivePort.close();
        workerIsolate.kill(priority: Isolate.immediate);
        debugPrint('Main Isolate: Worker stopped.');
      }
    }
  });
}

/// The Entry Point for the Worker Isolate.
/// Must be a top-level function or a static method.
void workerTask(SendPort mainSendPort) {
  // 1. Create a ReceivePort for this worker isolate
  final workerReceivePort = ReceivePort();

  // 2. Send the worker's SendPort back to the main isolate immediately
  mainSendPort.send(workerReceivePort.sendPort);

  // 3. Listen for incoming commands or data from the main isolate
  workerReceivePort.listen((message) {
    debugPrint('Worker Isolate received command: $message');

    if (message is String && message.startsWith('ProcessData:')) {
      // Simulate heavy processing task
      final items = message.split(':');
      final dataToProcess = items.last;

      mainSendPort.send('Processing $dataToProcess...');

      // Do heavy computation here...

      mainSendPort.send('Result of $dataToProcess: Success');
      mainSendPort.send('Task Complete');
    }
  });
}

/*
    Main Isolate
    │
    │ Isolate.spawn()
    ▼
    Worker Isolate
    │
    │ SendPort পাঠায়
    ▼
    Main Isolate
    │
    │ "ProcessData:Item1" পাঠায়
    ▼
    Worker Isolate
    │
    │ Processing করে
    ▼
    Main Isolate
    │
    ├── "Processing Item1..."
    ├── "Result of Item1: Success"
    └── "Task Complete"
*/