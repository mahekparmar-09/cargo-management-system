package test;
import java.sql.Connection;
import db_config.GetConnection;
public class DBTestRun {
    public static void main(String[] args) {
        System.out.println("Starting Database Connection Test...");
        Connection con = GetConnection.getConnection();
        if (con != null) {
            System.out.println("TEST SUCCESS: Database Connected");
        } else {
            System.out.println("TEST FAILED: Connection Not Established");
        }
        System.out.println("Test Finished.");
    }
}