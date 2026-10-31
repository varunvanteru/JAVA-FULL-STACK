package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
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
 * Module 9 - Programming Missions and Question Display.
 * Loads missions from MySQL (WITHOUT the correct answer) and forwards to missions.jsp.
 * Optional filters: ?category=Java|SQL|DSA  &difficulty=Easy|Medium|Hard
 */
@WebServlet("/missions")
public class MissionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final List<String> CATEGORIES = Arrays.asList("Java", "SQL", "DSA");
    private static final List<String> DIFFICULTIES = Arrays.asList("Easy", "Medium", "Hard");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        String category = request.getParameter("category");
        String difficulty = request.getParameter("difficulty");
        if (!CATEGORIES.contains(category)) {
            category = null;
        }
        if (!DIFFICULTIES.contains(difficulty)) {
            difficulty = null;
        }

        // NOTE: correct_answer is deliberately NOT selected here.
        StringBuilder sql = new StringBuilder(
                "SELECT m.id, m.title, m.description, m.category, m.difficulty, "
              + "m.option_a, m.option_b, m.option_c, m.option_d, m.xp_reward, "
              + "s.id AS submission_id, s.is_correct "
              + "FROM missions m "
              + "LEFT JOIN mission_submissions s ON s.mission_id = m.id AND s.user_id = ? "
              + "WHERE 1 = 1 ");
        if (category != null) {
            sql.append("AND m.category = ? ");
        }
        if (difficulty != null) {
            sql.append("AND m.difficulty = ? ");
        }
        sql.append("ORDER BY FIELD(m.category, 'Java', 'SQL', 'DSA'), "
                 + "FIELD(m.difficulty, 'Easy', 'Medium', 'Hard'), m.id");

        List<Mission> missions = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int i = 1;
            ps.setInt(i++, userId);
            if (category != null) {
                ps.setString(i++, category);
            }
            if (difficulty != null) {
                ps.setString(i++, difficulty);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Mission m = new Mission();
                    m.setId(rs.getInt("id"));
                    m.setTitle(rs.getString("title"));
                    m.setDescription(rs.getString("description"));
                    m.setCategory(rs.getString("category"));
                    m.setDifficulty(rs.getString("difficulty"));
                    m.setOptionA(rs.getString("option_a"));
                    m.setOptionB(rs.getString("option_b"));
                    m.setOptionC(rs.getString("option_c"));
                    m.setOptionD(rs.getString("option_d"));
                    m.setXpReward(rs.getInt("xp_reward"));
                    rs.getInt("submission_id");
                    m.setAttempted(!rs.wasNull());
                    m.setSolvedCorrectly(rs.getBoolean("is_correct"));
                    missions.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: could not load missions. " + e.getMessage());
        }

        request.setAttribute("missions", missions);
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedDifficulty", difficulty);
        request.getRequestDispatcher("missions.jsp").forward(request, response);
    }
}
