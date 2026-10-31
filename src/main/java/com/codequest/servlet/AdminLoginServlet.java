package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.codequest.util.DBConnection;
import com.codequest.util.PasswordUtil;

import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 4 - Admin Login.
 *
 * ServletConfig demo : init-param "adminHomePage" (only this servlet can read it).
 * ServletContext demo: context-param "appName" from web.xml (shared by the whole app),
 *                      plus an application-wide attribute counting admin logins.
 */
@WebServlet(
    urlPatterns = "/admin-login",
    initParams = {
        @WebInitParam(name = "adminHomePage", value = "admin-dashboard.jsp"),
        @WebInitParam(name = "sessionTimeoutMinutes", value = "20")
    }
)
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String adminHomePage;
    private int sessionTimeoutMinutes;

    @Override
    public void init(ServletConfig config) throws ServletException {
        super.init(config);
        // ---- ServletConfig: values private to this servlet ----
        adminHomePage = config.getInitParameter("adminHomePage");
        sessionTimeoutMinutes = Integer.parseInt(config.getInitParameter("sessionTimeoutMinutes"));

        // ---- ServletContext: value shared by the whole application ----
        ServletContext context = config.getServletContext();
        context.setAttribute("adminLoginCount", 0);
        System.out.println("[" + context.getInitParameter("appName") + "] AdminLoginServlet initialised");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("admin-login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        username = username == null ? "" : username.trim();
        request.setAttribute("username", username);

        if (username.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Please enter admin username and password.");
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT id, username FROM admins WHERE username = ? AND password = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, PasswordUtil.hash(password));

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // separate admin session: drop any student session first
                    HttpSession old = request.getSession(false);
                    if (old != null) {
                        old.invalidate();
                    }
                    HttpSession session = request.getSession(true);
                    session.setAttribute("adminId", rs.getInt("id"));
                    session.setAttribute("adminUsername", rs.getString("username"));
                    session.setAttribute("role", "admin");
                    session.setMaxInactiveInterval(sessionTimeoutMinutes * 60);

                    // update application-wide counter (ServletContext)
                    ServletContext context = getServletContext();
                    synchronized (context) {
                        Integer count = (Integer) context.getAttribute("adminLoginCount");
                        context.setAttribute("adminLoginCount", count == null ? 1 : count + 1);
                    }

                    response.sendRedirect(adminHomePage);
                } else {
                    request.setAttribute("error", "Invalid admin credentials.");
                    request.getRequestDispatcher("admin-login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: unable to log in right now. " + e.getMessage());
            request.getRequestDispatcher("admin-login.jsp").forward(request, response);
        }
    }
}
