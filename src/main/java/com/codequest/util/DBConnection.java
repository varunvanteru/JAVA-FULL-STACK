package com.codequest.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Reusable JDBC connection class (Module 5).
 * Every Servlet / JSP calls DBConnection.getConnection()
 * so the database configuration lives in ONE place.
 */
public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/codequest_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "Varun@1234";   // <-- change this

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "MySQL JDBC driver not found. Add mysql-connector-j jar to WEB-INF/lib", e);
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }
}
