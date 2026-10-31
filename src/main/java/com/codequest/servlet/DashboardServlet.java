package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.codequest.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 8 - Student Dashboard and Progress Tracking.
 * Uses the userId stored in the session to fetch the latest stats.
 * ServletContext demo: XP needed per level comes from context-param "xpPerLevel".
 */
@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");
        int xpPerLevel = Integer.parseInt(getServletContext().getInitParameter("xpPerLevel"));

        String userSql = "SELECT username, email, total_xp, player_level, created_at FROM users WHERE id = ?";
        String statsSql = "SELECT "
                + " (SELECT COUNT(*) FROM mission_submissions WHERE user_id = ? AND is_correct = TRUE) AS correct_count, "
                + " (SELECT COUNT(*) FROM mission_submissions WHERE user_id = ?) AS attempted_count, "
                + " (SELECT COUNT(*) FROM missions) AS total_missions";

        try (Connection con = DBConnection.getConnection()) {

            try (PreparedStatement ps = con.prepareStatement(userSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        // user deleted from DB while logged in
                        session.invalidate();
                        response.sendRedirect("login.jsp?msg=loginRequired");
                        return;
                    }
                    int totalXp = rs.getInt("total_xp");
                    int level = rs.getInt("player_level");
                    int xpIntoLevel = totalXp - (level - 1) * xpPerLevel;
                    if (xpIntoLevel < 0) {
                        xpIntoLevel = 0;
                    }
                    int progressPercent = Math.min(100, xpIntoLevel * 100 / xpPerLevel);

                    request.setAttribute("username", rs.getString("username"));
                    request.setAttribute("email", rs.getString("email"));
                    request.setAttribute("totalXp", totalXp);
                    request.setAttribute("level", level);
                    request.setAttribute("memberSince", rs.getTimestamp("created_at"));
                    request.setAttribute("xpIntoLevel", xpIntoLevel);
                    request.setAttribute("xpPerLevel", xpPerLevel);
                    request.setAttribute("xpToNext", xpPerLevel - xpIntoLevel);
                    request.setAttribute("progressPercent", progressPercent);
                }
            }

            try (PreparedStatement ps = con.prepareStatement(statsSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("correctCount", rs.getInt("correct_count"));
                        request.setAttribute("attemptedCount", rs.getInt("attempted_count"));
                        request.setAttribute("totalMissions", rs.getInt("total_missions"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: could not load your progress. " + e.getMessage());
        }

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
