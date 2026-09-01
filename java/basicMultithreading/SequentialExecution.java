public class SequentialExecution {
    public static void main(String[] args) {
        System.out.println("Starting sequential execution...");

        // Step 1: Perform the first task
        performTask1();

        // Step 2: Perform the second task
        performTask2();

        // Step 3: Perform the third task
        performTask3();

        System.out.println("Sequential execution completed.");
    }

    private static void performTask1() {
        System.out.println("Performing Task 1...");
        // Simulate some work with a sleep
        try {
            Thread.sleep(1000); // Sleep for 1 second
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Task 1 completed.");
    }

    private static void performTask2() {
        System.out.println("Performing Task 2...");
        // Simulate some work with a sleep
        try {
            Thread.sleep(1000); // Sleep for 1 second
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Task 2 completed.");
    }

    private static void performTask3() {
        System.out.println("Performing Task 3...");
        // Simulate some work with a sleep
        try {
            Thread.sleep(1000); // Sleep for 1 second
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("Task 3 completed.");
    }
}