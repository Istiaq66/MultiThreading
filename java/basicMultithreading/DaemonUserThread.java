
public class DaemonUserThread {

    public static void main(String[] args) {
        Thread bgThread = new Thread(new DaemonHelper());
        Thread usrThread = new Thread(new UserThreadHelper());
        bgThread.setDaemon(true);
        
        bgThread.start();
        usrThread.start();
    }
}

class DaemonHelper implements Runnable {

    @Override
    public void run() {
        int count = 0;
        while (count < 500) {
            try {
                Thread.sleep(1000);
            } catch (InterruptedException ex) {
                System.getLogger(DaemonHelper.class.getName()).log(System.Logger.Level.ERROR, (String) null, ex);
            }
            count++;
            System.out.println("Daemon Helper Running ...");
        }
    }

}

class UserThreadHelper implements Runnable {

    @Override
    public void run() {
        try {
            Thread.sleep(1000);
        } catch (InterruptedException ex) {
            System.getLogger(UserThread.class.getName()).log(System.Logger.Level.ERROR, (String) null, ex);
        }
        System.out.println("User Thread Done with execution ...");
    }

}
