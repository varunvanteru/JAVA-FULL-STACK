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
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 3 - Student Login.
 * Login with username OR email + password, creates an HttpSession,
 * and uses a "Remember me" cookie to pre-fill the username next time.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static final String REMEMBER_COOKIE = "cq_remember_user";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");

        identifier = identifier == null ? "" : identifier.trim();
        request.setAttribute("identifier", identifier);

        if (identifier.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Please enter your username/email and password.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username FROM users WHERE (username = ? OR email = ?) AND password = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, identifier);
            ps.setString(2, identifier);
            ps.setString(3, PasswordUtil.hash(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // destroy any old session (e.g. an admin session) and start a fresh student session
                    HttpSession old = request.getSession(false);
                    if (old != null) {
                        old.invalidate();
                    }
                    HttpSession session = request.getSession(true);
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("role", "student");
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes

                    // ---- Cookie demo: remember username ----
                    Cookie cookie = new Cookie(REMEMBER_COOKIE, rs.getString("username"));
                    cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                    cookie.setHttpOnly(true);
                    cookie.setMaxAge("on".equals(remember) ? 7 * 24 * 60 * 60 : 0); // 0 = delete
                    response.addCookie(cookie);

                    response.sendRedirect("dashboard");
                } else {
                    request.setAttribute("error", "Invalid username/email or password.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: unable to log in right now. " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
