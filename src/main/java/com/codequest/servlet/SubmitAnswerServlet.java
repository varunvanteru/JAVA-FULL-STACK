package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import com.codequest.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 10 - Answer Evaluation and XP Rewards.
 *
 * Rules:
 *  - One attempt per mission (checked in code AND by UNIQUE(user_id, mission_id) in the DB).
 *  - Correct answer  -> save submission, add XP, recalculate level.
 *  - Wrong answer    -> save submission (attempt used), no XP.
 *  - Submission insert + XP update run inside ONE transaction.
 */
@WebServlet("/submit-answer")
public class SubmitAnswerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("missions");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?msg=loginRequired");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");
        int xpPerLevel = Integer.parseInt(getServletContext().getInitParameter("xpPerLevel"));

        String answer = request.getParameter("answer");
        int missionId;
        try {
            missionId = Integer.parseInt(request.getParameter("missionId"));
        } catch (NumberFormatException e) {
            response.sendRedirect("missions?msg=invalidMission");
            return;
        }
        if (answer == null || answer.trim().isEmpty()) {
            response.sendRedirect("missions?msg=noAnswer#mission-" + missionId);
            return;
        }
        answer = answer.trim();

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);   // ---- start transaction ----

            // 1. fetch the mission + correct answer from the DB (never from the form)
            String title;
            String correctAnswer;
            int xpReward;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT title, correct_answer, xp_reward FROM missions WHERE id = ?")) {
                ps.setInt(1, missionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        response.sendRedirect("missions?msg=invalidMission");
                        return;
                    }
                    title = rs.getString("title");
                    correctAnswer = rs.getString("correct_answer");
                    xpReward = rs.getInt("xp_reward");
                }
            }

            // 2. one-attempt-per-mission check
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM mission_submissions WHERE user_id = ? AND mission_id = ?")) {
                ps.setInt(1, userId);
                ps.setInt(2, missionId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        con.rollback();
                        response.sendRedirect("missions?msg=alreadyAttempted#mission-" + missionId);
                        return;
                    }
                }
            }

            boolean correct = correctAnswer.trim().equals(answer);

            // 3. record the submission
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO mission_submissions (user_id, mission_id, answer, is_correct) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, userId);
                ps.setInt(2, missionId);
                ps.setString(3, answer);
                ps.setBoolean(4, correct);
                ps.executeUpdate();
            }

            // 4. read current XP / level (locked for update)
            int oldXp;
            int oldLevel;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT total_xp, player_level FROM users WHERE id = ? FOR UPDATE")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    oldXp = rs.getInt("total_xp");
                    oldLevel = rs.getInt("player_level");
                }
            }

            int newXp = oldXp;
            int newLevel = oldLevel;
            int xpEarned = 0;

            // 5. award XP and update level only when correct
            if (correct) {
                xpEarned = xpReward;
                newXp = oldXp + xpReward;
                newLevel = newXp / xpPerLevel + 1;
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE users SET total_xp = ?, player_level = ? WHERE id = ?")) {
                    ps.setInt(1, newXp);
                    ps.setInt(2, newLevel);
                    ps.setInt(3, userId);
                    ps.executeUpdate();
                }
            }

            con.commit();   // ---- end transaction ----

            request.setAttribute("missionTitle", title);
            request.setAttribute("submittedAnswer", answer);
            request.setAttribute("correctAnswer", correctAnswer);
            request.setAttribute("correct", correct);
            request.setAttribute("xpEarned", xpEarned);
            request.setAttribute("totalXp", newXp);
            request.setAttribute("oldLevel", oldLevel);
            request.setAttribute("newLevel", newLevel);
            request.setAttribute("levelUp", newLevel > oldLevel);
            request.getRequestDispatcher("mission-result.jsp").forward(request, response);

        } catch (SQLIntegrityConstraintViolationException dup) {
            // UNIQUE(user_id, mission_id) caught a double-click / double submit
            rollbackQuietly(con);
            response.sendRedirect("missions?msg=alreadyAttempted#mission-" + missionId);
        } catch (SQLException e) {
            e.printStackTrace();
            rollbackQuietly(con);
            response.sendRedirect("missions?msg=dbError");
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    private void rollbackQuietly(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException ignored) {
            }
        }
    }
}
