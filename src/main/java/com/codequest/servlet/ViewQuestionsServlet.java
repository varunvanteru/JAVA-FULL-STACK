package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.codequest.model.Mission;
import com.codequest.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 7 - Admin Question Management.
 * Reads all missions with JDBC and forwards them to view-questions.jsp
 * using RequestDispatcher.
 */
@WebServlet("/view-questions")
public class ViewQuestionsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect("admin-login.jsp?msg=adminRequired");
            return;
        }

        List<Mission> missions = new ArrayList<>();
        String sql = "SELECT id, title, category, difficulty, correct_answer, xp_reward FROM missions "
                + "ORDER BY FIELD(category, 'Java', 'SQL', 'DSA'), "
                + "FIELD(difficulty, 'Easy', 'Medium', 'Hard'), id";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Mission m = new Mission();
                m.setId(rs.getInt("id"));
                m.setTitle(rs.getString("title"));
                m.setCategory(rs.getString("category"));
                m.setDifficulty(rs.getString("difficulty"));
                m.setCorrectAnswer(rs.getString("correct_answer")); // admin may see the answer
                m.setXpReward(rs.getInt("xp_reward"));
                missions.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: could not load questions. " + e.getMessage());
        }

        request.setAttribute("missions", missions);
        request.getRequestDispatcher("view-questions.jsp").forward(request, response);
    }
}
