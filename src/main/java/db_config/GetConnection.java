package db_config;
import java.sql.Connection;
import java.sql.DriverManager;
public class GetConnection {
    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = System.getenv("DB_URL");
            String user = System.getenv("DB_USER");
            String password = System.getenv("DB_PASSWORD");
            System.out.println("DB_URL = " + url);
            System.out.println("DB_USER = " + user);
            if (url == null || user == null || password == null) {
                System.out.println("ENV VARIABLES MISSING");
                return null;
            }
            con = DriverManager.getConnection(url, user, password);
            System.out.println("DATABASE CONNECTED SUCCESSFULLY");
        } catch (Exception e) {
            System.out.println("DATABASE CONNECTION FAILED");
            e.printStackTrace();
        }
        return con;
    }
}