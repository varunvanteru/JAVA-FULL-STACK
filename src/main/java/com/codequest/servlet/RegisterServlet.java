package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.codequest.util.DBConnection;
import com.codequest.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Module 2 - Student Registration.
 * Validates the form, checks unique username/email and inserts into users
 * with total_xp = 0 and player_level = 1.
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = trim(request.getParameter("username"));
        String email = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // keep typed values so the form is not cleared on error
        request.setAttribute("username", username);
        request.setAttribute("email", email);

        // ---------- validation ----------
        String error = null;
        if (username.isEmpty() || email.isEmpty() || password == null || password.isEmpty()
                || confirmPassword == null || confirmPassword.isEmpty()) {
            error = "All fields are required.";
        } else if (!username.matches("[A-Za-z0-9_]{3,50}")) {
            error = "Username must be 3-50 characters (letters, numbers, underscore).";
        } else if (email.length() > 100 || !email.matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            error = "Please enter a valid email address.";
        } else if (password.length() < 6) {
            error = "Password must be at least 6 characters long.";
        } else if (!password.equals(confirmPassword)) {
            error = "Password and Confirm Password do not match.";
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // ---------- uniqueness check + insert ----------
        try (Connection con = DBConnection.getConnection()) {

            String checkSql = "SELECT username, email FROM users WHERE username = ? OR email = ?";
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if (rs.getString("username").equalsIgnoreCase(username)) {
                            error = "Username '" + username + "' is already taken.";
                        } else {
                            error = "Email '" + email + "' is already registered.";
                        }
                    }
                }
            }

            if (error != null) {
                request.setAttribute("error", error);
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            String insertSql = "INSERT INTO users (username, email, password, total_xp, player_level) "
                    + "VALUES (?, ?, ?, 0, 1)";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, PasswordUtil.hash(password));
                ps.executeUpdate();
            }

            // Post-Redirect-Get: go to login page with a success message
            response.sendRedirect("login.jsp?msg=registered");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: could not register right now. " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
