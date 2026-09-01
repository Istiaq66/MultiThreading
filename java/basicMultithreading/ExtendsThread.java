
public class ExtendsThread {

    public static void main(String[] args) {
      Thread1 thread1 = new Thread1();
      Thread2 thread2 = new Thread2();
      
      thread1.start();
      thread2.start();
    
    }

}

class Thread1 extends Thread {

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("Thread1: " + i);
        }
    }
}


class Thread2 extends Thread {

    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println("Thread2: " + i);
        }
    }
}