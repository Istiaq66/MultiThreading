package executorService;

import java.util.concurrent.*;

public class CallableDemo {
    public static void main(String[] args) throws ExecutionException, InterruptedException, TimeoutException {
        ExecutorService executorService = Executors.newFixedThreadPool(2);
        try {
            Future<Integer> result = executorService.submit(new ReturnValueTask());

            /*result.cancel(true);

            boolean cancelled = result.isCancelled();

            boolean done = result.isDone();*/

            System.out.println(result.get(6, TimeUnit.SECONDS));
            System.out.println("Main thread execution completed!");
        } finally {
            executorService.shutdown();
        }
    }
}

class ReturnValueTask implements Callable<Integer> {
    @Override
    public Integer call() throws Exception {
        Thread.sleep(5000);
        return 12;
    }
}
