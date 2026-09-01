/*
 * ============================
 *       RACE CONDITION
 * ============================
 *
 * THEORY:
 *
 * A Race Condition occurs when two or more threads access and modify
 * the same shared resource at the same time, and the final result
 * depends on the order in which the threads execute.
 *
 * In Java, the statement:
 *
 *     count++;
 *
 * is not an atomic operation. It actually involves:
 *
 *     1. Read the current value of count
 *     2. Add 1
 *     3. Write the new value back
 *
 * If two threads perform these operations simultaneously, both threads
 * may read the same value and overwrite each other's updates.
 *
 * Example:
 *
 * Initial count = 0
 *
 * Thread 1 reads count = 0
 * Thread 2 reads count = 0
 *
 * Thread 1 writes count = 1
 * Thread 2 writes count = 1
 *
 * Expected result = 2
 * Actual result    = 1
 *
 * This is called a Race Condition.
 *
 *
 * ============================
 *       RACE CONDITION EXAMPLE
 * ============================
 */

class Counter {

    int count = 0;

    void increment() {
        count++;
    }
}

public class Main {

    public static void main(String[] args) throws InterruptedException {

        Counter counter = new Counter();

        // First thread
        Thread t1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                counter.increment();
            }
        });

        // Second thread
        Thread t2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                counter.increment();
            }
        });

        // Start both threads
        t1.start();
        t2.start();

        // Wait for both threads to finish
        t1.join();
        t2.join();

        System.out.println("Final Count: " + counter.count);
    }
}


/*
 * ============================
 *       PROBLEM
 * ============================
 *
 * We expect:
 *
 *     1000 + 1000 = 2000
 *
 * But the program may produce:
 *
 *     Final Count: 1875
 *     Final Count: 1932
 *     Final Count: 1991
 *
 * etc.
 *
 * The result is unpredictable because both threads are modifying
 * the same variable at the same time.
 *
 *
 * ============================
 *       SOLUTION
 * ============================
 *
 * We can use the synchronized keyword to make the increment()
 * method thread-safe.
 *
 * Only one thread will be allowed to execute the synchronized
 * method at a time.
 */

class SafeCounter {

    int count = 0;

    synchronized void increment() {
        count++;
    }
}

@SuppressWarnings("unused")
class SafeMain {

    public static void main(String[] args) throws InterruptedException {

        SafeCounter counter = new SafeCounter();

        Thread t1 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                counter.increment();
            }
        });

        Thread t2 = new Thread(() -> {
            for (int i = 0; i < 1000; i++) {
                counter.increment();
            }
        });

        t1.start();
        t2.start();

        t1.join();
        t2.join();

        // Now the result will always be 2000
        System.out.println("Final Count: " + counter.count);
    }
}

/*
 * ============================
 *       KEY POINTS
 * ============================
 *
 * Race Condition:
 * Multiple threads access shared data simultaneously and produce
 * an unpredictable or incorrect result.
 *
 * Shared Resource:
 * Data that is accessed by multiple threads.
 *
 * synchronized:
 * Ensures that only one thread can execute the synchronized method
 * at a time for the same object.
 *
 * Prevention:
 * - synchronized
 * - Locks / ReentrantLock
 * - Atomic variables
 * - Proper thread synchronization
 *
 * In short:
 *
 * Multiple Threads
 *        ↓
 * Shared Resource
 *        ↓
 * Simultaneous Access
 *        ↓
 * Race Condition
 *        ↓
 * Unexpected Result
 */