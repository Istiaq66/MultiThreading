
public class RunnableThread extends Thread {

    public static void main(String[] args) {
        Thread one = new Thread(new ThreadOne());
        Thread two = new Thread(new ThreadTwo());
        Thread three = new Thread(() -> {
            for (int i = 0; i < 5; i++) {
                System.out.println("ThreadThree: " + i);
            }
        });

        one.start();
        two.start();
        three.start();
    }
}

class ThreadOne implements Runnable {

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("ThreadOne: " + i);
        }
    }

}

class ThreadTwo implements Runnable {

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("ThreadTwo: " + i);
        }
    }

}
