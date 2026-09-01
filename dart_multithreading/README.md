# Dart/Flutter Concurrency: Normal Function vs Isolate.spawn() vs compute()

This README compares three approaches for running a CPU-heavy task in
Dart/Flutter:

1.  Normal function
2.  `Isolate.spawn()`
3.  `compute()`

The comparison is based on the provided Flutter documentation about
concurrency and isolates.

------------------------------------------------------------------------

## 1. Why Do We Need Isolates?

Flutter normally runs application work on a single **main isolate**. The
main isolate handles things such as user input, executing functions, and
painting frames.

If a computation takes longer than the available frame time, it can
cause **UI jank** or make the application unresponsive.

A helper isolate can run the heavy computation concurrently with the
main isolate, allowing the UI isolate to continue working.

> Use isolates when large computations are causing UI jank.

Common examples include:

-   Parsing and decoding large data
-   Reading data from a local database
-   Processing or compressing photos, audio, or video
-   Converting audio or video
-   Filtering complex lists or filesystems
-   CPU-heavy FFI-related work

------------------------------------------------------------------------

# 2. Normal Function

``` dart
Future<void> main() async {
  print('Before task triggered');

  processDataNormal();

  print('After task triggered');
}

void processDataNormal() {
  for (int i = 0; i < 100000000; i++) {
    // Heavy processing
  }

  print('Data Processing Done - Normal');
}
```

### How it works

The function executes on the **main isolate**.

``` text
Main Isolate
     |
     v
processDataNormal()
     |
     v
Heavy computation
     |
     v
After task triggered
```

The main isolate cannot process other events while the synchronous
computation is running.

### Result

``` text
Before task triggered
Data Processing Done - Normal
After task triggered
```

The heavy computation finishes before `After task triggered` can
execute.

### Use when

Use a normal function when the computation is small enough that it does
not cause UI jank.

------------------------------------------------------------------------

# 3. Isolate.spawn()

``` dart
import 'dart:isolate';

Future<void> main() async {
  print('Before task triggered');

  final receivePort = ReceivePort();

  await Isolate.spawn(
    processDataIsolate,
    receivePort.sendPort,
  );

  receivePort.listen((message) {
    print(message);
    receivePort.close();
  });

  print('After task triggered');

  await Future.delayed(const Duration(seconds: 1));
}

void processDataIsolate(SendPort sendPort) {
  for (int i = 0; i < 100000000; i++) {
    // Heavy processing
  }

  sendPort.send('Data Processing Done - Isolate');
}
```

### How it works

`Isolate.spawn()` creates another isolate.

``` text
             Main Isolate
                  |
                  | SendPort
                  v
            Worker Isolate
                  |
            Heavy computation
                  |
                  | send()
                  v
             ReceivePort
                  |
                  v
             Main Isolate
```

Unlike shared-memory threads, Dart isolates have their **own memory and
event loop**. They communicate through message passing.

`ReceivePort` receives messages and `SendPort` sends messages.

### Result

The main isolate can continue while the worker isolate performs the
heavy computation.

``` text
Before task triggered
After task triggered
Data Processing Done - Isolate
```

### Important characteristics

-   Low-level isolate API
-   Manual `SendPort` / `ReceivePort` communication
-   Suitable for long-lived background workers
-   Can send multiple messages over time
-   More setup and lifecycle management
-   Useful when you need an isolate that stays alive and processes
    repeated work

The Flutter documentation describes `Isolate.spawn()`, `ReceivePort`,
and `SendPort` as the lower-level APIs used to build longer-lived
isolates.

------------------------------------------------------------------------

# 4. compute()

``` dart
import 'package:flutter/foundation.dart';

Future<void> main() async {
  print('Before task triggered');

  final result = await compute(
    processDataCompute,
    100000000,
  );

  print(result);

  print('After task triggered');
}

String processDataCompute(int count) {
  for (int i = 0; i < count; i++) {
    // Heavy processing
  }

  return 'Data Processing Done - Compute';
}
```

### How it works

`compute()` provides a simpler API for running a computation in another
isolate on mobile and desktop.

Conceptually:

``` text
Main Isolate
     |
     | compute()
     v
Worker Isolate
     |
Heavy computation
     |
     | return result
     v
Main Isolate
```

On mobile and desktop:

``` dart
await compute(fun, message);
```

is equivalent to:

``` dart
await Isolate.run(() => fun(message));
```

according to the Flutter documentation.

### Important characteristics

-   High-level and simple API
-   No manual `SendPort` / `ReceivePort`
-   Best suited to a single computation that produces one result
-   The spawned isolate exits after the computation completes
-   Less boilerplate than `Isolate.spawn()`

------------------------------------------------------------------------

# 5. Core Differences

  ----------------------------------------------------------------------------
  Feature           Normal Function   `Isolate.spawn()`   `compute()`
  ----------------- ----------------- ------------------- --------------------
  Runs on           Main isolate      Separate isolate    Separate isolate on
                                                          mobile/desktop

  Blocks main       Yes               No                  No
  isolate during                                          
  synchronous work                                        

  Manual ports      No                Yes                 No
  required                                                

  Returns a result  Yes               No, use messages    Yes, via `Future`
  directly                                                

  Long-lived worker No                Yes                 No

  Multiple messages Not applicable    Yes                 Designed for one
                                                          computation/result

  Boilerplate       Lowest            Highest             Low

  Best for          Small/simple work Repeated or         One-off CPU-heavy
                                      long-running        work
                                      background work     

  Web behavior      Main thread       Isolates not        Runs on main thread
                                      supported on web    on web
  ----------------------------------------------------------------------------

------------------------------------------------------------------------

# 6. `Isolate.spawn()` vs `compute()`

The biggest difference is **control vs convenience**.

### `Isolate.spawn()`

You manage the isolate yourself:

``` text
Create isolate
     ↓
Create ReceivePort
     ↓
Pass SendPort
     ↓
Worker processes data
     ↓
Worker sends messages
     ↓
Main isolate receives messages
     ↓
Manage lifecycle
```

This makes it more appropriate for a **long-lived worker** that performs
work repeatedly or sends multiple results over time.

### `compute()`

Flutter handles the isolate lifecycle and communication:

``` text
compute()
   ↓
Create temporary isolate
   ↓
Run callback
   ↓
Return result
   ↓
Isolate exits
```

This makes it appropriate for a **short-lived, one-off computation**.

------------------------------------------------------------------------

# 7. Why Isolate.run() Matters

The Flutter documentation identifies `Isolate.run()` as the easiest way
to move a process to another isolate.

Example:

``` dart
final result = await Isolate.run(() {
  return heavyComputation();
});
```

`Isolate.run()`:

-   Creates a new isolate
-   Runs the callback there
-   Returns the callback's result
-   Shuts down the isolate when complete
-   Does not block the main isolate

The documentation also explains that both `Isolate.run()` and
`compute()` use `Isolate.exit()` internally when returning their result.

For a one-off computation, `Isolate.run()` can therefore be a simpler
alternative to manually managing `Isolate.spawn()`.

------------------------------------------------------------------------

# 8. Memory and Communication

Dart isolates **do not share mutable memory**.

Each isolate has:

-   Its own memory
-   Its own event loop
-   Its own global fields

Communication happens through messages.

When mutable objects are passed between isolates, they are generally
copied.

Immutable objects, such as `String`, can be transferred more efficiently
because they cannot be modified.

This means you should not think of Dart isolates as traditional
shared-memory threads.

------------------------------------------------------------------------

# 9. Important Limitations

## UI work

Flutter UI work is coupled to the main isolate.

A background isolate cannot directly perform widget/UI work.

For example, you cannot move normal widget operations into an isolate.

## rootBundle

The documentation states that spawned isolates cannot access assets
using `rootBundle`.

## Web

Dart web platforms do not support isolates in the same way as
mobile/desktop.

`compute()` still works on the web, but the computation runs on the
**main thread**.

Therefore:

``` text
Mobile/Desktop:
compute()
    ↓
Separate isolate

Web:
compute()
    ↓
Main thread
```

So `compute()` provides portability, but it does not give true
background-thread execution on Flutter Web.

## Plugins

Background isolates can use platform plugins in supported scenarios, but
there are limitations.

For example, a long-lived Firestore listener cannot be moved to a
background isolate because Firestore can send unsolicited updates from
the host platform.

------------------------------------------------------------------------

# 10. Which One Should I Use?

### Small computation

Use a normal function:

``` dart
processData();
```

If it is fast enough that it does not cause UI jank, there is no reason
to introduce isolate overhead.

### One-time heavy computation

Prefer `compute()` or `Isolate.run()`:

``` dart
final result = await compute(processData, data);
```

or:

``` dart
final result = await Isolate.run(() => processData(data));
```

These APIs are designed for short-lived computations.

### Long-running/repeated background work

Use `Isolate.spawn()`:

``` text
Main Isolate
      |
      v
Long-lived Worker Isolate
      |
      +--> Task 1
      +--> Result 1
      +--> Task 2
      +--> Result 2
      +--> Task 3
      +--> Result 3
```

This gives you control over communication and the worker's lifetime.

------------------------------------------------------------------------

# 11. Simple Mental Model

Remember it like this:

``` text
NORMAL FUNCTION
---------------
Same isolate
Simple
Can block UI


Isolate.spawn()
---------------
Separate isolate
Manual communication
Long-lived worker
Maximum control


compute()
---------
Separate isolate on mobile/desktop
Simple API
One-off computation
Automatic lifecycle
```

------------------------------------------------------------------------

# 12. Final Summary

The three approaches solve different problems:

-   **Normal function:** simplest, but CPU-heavy synchronous work runs
    on the main isolate and can cause UI jank.
-   **`Isolate.spawn()`:** low-level and flexible; use it when you need
    a long-lived worker or repeated/multiple message communication.
-   **`compute()`:** convenient high-level API for short-lived CPU-heavy
    work where you want a result without manually managing ports.
-   **`Isolate.run()`:** another simple short-lived isolate API; on
    mobile/desktop, `compute()` is effectively implemented in terms of
    `Isolate.run()`.

The key principle from Flutter's documentation is:

> Use isolates when large computations are causing UI jank.

------------------------------------------------------------------------

## Reference

Flutter documentation: **Concurrency and isolates**

https://docs.flutter.dev/perf/isolates
