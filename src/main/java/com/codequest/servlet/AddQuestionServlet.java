package com.codequest.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

import com.codequest.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Module 6 - Admin Question Creation.
 * Only an authenticated admin can insert questions into the missions table.
 * ServletConfig demo: default / max XP reward come from init-params.
 */
@WebServlet(
    urlPatterns = "/add-question",
    initParams = {
        @WebInitParam(name = "defaultXpReward", value = "50"),
        @WebInitParam(name = "maxXpReward", value = "500")
    }
)
public class AddQuestionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final List<String> CATEGORIES = Arrays.asList("Java", "SQL", "DSA");
    private static final List<String> DIFFICULTIES = Arrays.asList("Easy", "Medium", "Hard");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.sendRedirect("admin-login.jsp?msg=adminRequired");
            return;
        }
        request.getRequestDispatcher("add-question.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect("admin-login.jsp?msg=adminRequired");
            return;
        }

        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String category = trim(request.getParameter("category"));
        String difficulty = trim(request.getParameter("difficulty"));
        String optionA = trim(request.getParameter("optionA"));
        String optionB = trim(request.getParameter("optionB"));
        String optionC = trim(request.getParameter("optionC"));
        String optionD = trim(request.getParameter("optionD"));
        String correctOption = trim(request.getParameter("correctOption")); // A, B, C or D
        String xpText = trim(request.getParameter("xpReward"));

        int defaultXp = Integer.parseInt(getServletConfig().getInitParameter("defaultXpReward"));
        int maxXp = Integer.parseInt(getServletConfig().getInitParameter("maxXpReward"));

        // ---------- validation ----------
        String error = null;
        int xpReward = defaultXp;

        if (title.isEmpty() || description.isEmpty() || optionA.isEmpty() || optionB.isEmpty()
                || optionC.isEmpty() || optionD.isEmpty()) {
            error = "Title, description and all four answer choices are required.";
        } else if (title.length() > 100) {
            error = "Title must be at most 100 characters.";
        } else if (optionA.length() > 255 || optionB.length() > 255
                || optionC.length() > 255 || optionD.length() > 255) {
            error = "Each answer choice must be at most 255 characters.";
        } else if (!CATEGORIES.contains(category)) {
            error = "Please choose a valid category (Java, SQL or DSA).";
        } else if (!DIFFICULTIES.contains(difficulty)) {
            error = "Please choose a valid difficulty (Easy, Medium or Hard).";
        } else if (!Arrays.asList("A", "B", "C", "D").contains(correctOption)) {
            error = "Please choose which option (A, B, C or D) is correct.";
        } else if (hasDuplicateOptions(optionA, optionB, optionC, optionD)) {
            error = "The four answer choices must all be different.";
        } else if (!xpText.isEmpty()) {
            try {
                xpReward = Integer.parseInt(xpText);
                if (xpReward < 1 || xpReward > maxXp) {
                    error = "XP reward must be between 1 and " + maxXp + ".";
                }
            } catch (NumberFormatException e) {
                error = "XP reward must be a whole number.";
            }
        }

        if (error != null) {
            request.setAttribute("error", error);
            request.getRequestDispatcher("add-question.jsp").forward(request, response);
            return;
        }

        // store the TEXT of the correct option (as described in the table design)
        String correctAnswer;
        switch (correctOption) {
            case "A": correctAnswer = optionA; break;
            case "B": correctAnswer = optionB; break;
            case "C": correctAnswer = optionC; break;
            default:  correctAnswer = optionD;
        }

        int adminId = (Integer) request.getSession(false).getAttribute("adminId");

        String sql = "INSERT INTO missions (title, description, category, difficulty, option_a, option_b, "
                + "option_c, option_d, correct_answer, xp_reward, created_by) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, category);
            ps.setString(4, difficulty);
            ps.setString(5, optionA);
            ps.setString(6, optionB);
            ps.setString(7, optionC);
            ps.setString(8, optionD);
            ps.setString(9, correctAnswer);
            ps.setInt(10, xpReward);
            ps.setInt(11, adminId);
            ps.executeUpdate();

            response.sendRedirect("add-question.jsp?msg=added");
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: question was not saved. " + e.getMessage());
            request.getRequestDispatcher("add-question.jsp").forward(request, response);
        }
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("adminId") != null;
    }

    private boolean hasDuplicateOptions(String a, String b, String c, String d) {
        return a.equalsIgnoreCase(b) || a.equalsIgnoreCase(c) || a.equalsIgnoreCase(d)
                || b.equalsIgnoreCase(c) || b.equalsIgnoreCase(d) || c.equalsIgnoreCase(d);
    }

    private String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
