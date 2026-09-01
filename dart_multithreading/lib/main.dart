import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/bouncing-ball.gif', scale: 0.5),

              // ==================================================
              // 1. ASYNC / AWAIT
              // ==================================================
              ElevatedButton.icon(
                onPressed: () async {
                  final json = await fetchData(1000);

                  debugPrint('Async Await result: length - ${json.length}');
                },
                label: const Text('Async Await'),
                icon: const Icon(Icons.star),
              ),

              // ==================================================
              // 2. COMPUTE
              // ==================================================
              ElevatedButton.icon(
                onPressed: () async {
                  final json = await compute(fetchData, 1000);

                  debugPrint('Compute result: length - ${json.length}');
                },
                label: const Text('Compute'),
                icon: const Icon(Icons.star),
              ),

              // ==================================================
              // 3. ISOLATE.RUN
              // ==================================================
              ElevatedButton.icon(
                onPressed: () async {
                  final json = await Isolate.run(() => fetchDataSync(1000));

                  debugPrint('Isolate.run result: length - ${json.length}');
                },
                label: const Text('Isolate.run'),
                icon: const Icon(Icons.star),
              ),

              // ==================================================
              // 4. ISOLATE.SPAWN
              // ==================================================
              ElevatedButton.icon(
                onPressed: () async {
                  final receivePort = ReceivePort();

                  await Isolate.spawn(fetchDataIsolate, (
                    iteration: 1000,
                    sendPort: receivePort.sendPort,
                  ));

                  receivePort.listen((message) {
                    debugPrint('Isolate progress: $message%');
                  });
                },
                label: const Text('Isolate.spawn'),
                icon: const Icon(Icons.star),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // ASYNC / COMPUTE
  // ==============================================================

  Future<String> fetchData(int iteration) async {
    final jsonData = jsonEncode(
      List.generate(10000, (i) => {'id': i, 'value': 'value of $i'}),
    );

    for (var i = 0; i < iteration; i++) {
      jsonDecode(jsonData);
    }

    return jsonData;
  }
}

// ================================================================
// ISOLATE.RUN
// ================================================================

String fetchDataSync(int iteration) {
  final jsonData = jsonEncode(
    List.generate(10000, (i) => {'id': i, 'value': 'value of $i'}),
  );

  for (var i = 0; i < iteration; i++) {
    jsonDecode(jsonData);
  }

  return jsonData;
}

// ================================================================
// ISOLATE.SPAWN
// ================================================================

Future<void> fetchDataIsolate(({int iteration, SendPort sendPort}) data) async {
  final jsonData = jsonEncode(
    List.generate(10000, (i) => {'id': i, 'value': 'value of $i'}),
  );

  for (var i = 1; i <= data.iteration; i++) {
    jsonDecode(jsonData);

    final percentage = (i / data.iteration) * 100;

    if (percentage % 10 == 0) {
      data.sendPort.send(percentage);
    }
  }
}
