<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: admins only ----
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=adminRequired");
        return;
    }
    String error = (String) request.getAttribute("error");
    boolean added = "added".equals(request.getParameter("msg"));

    // re-fill the form after a validation error (values come back as request parameters on forward)
    String title = "", description = "", category = "", difficulty = "",
           optionA = "", optionB = "", optionC = "", optionD = "", correctOption = "", xpReward = "50";
    if (error != null) {
        title = request.getParameter("title");
        description = request.getParameter("description");
        category = request.getParameter("category");
        difficulty = request.getParameter("difficulty");
        optionA = request.getParameter("optionA");
        optionB = request.getParameter("optionB");
        optionC = request.getParameter("optionC");
        optionD = request.getParameter("optionD");
        correctOption = request.getParameter("correctOption");
        xpReward = request.getParameter("xpReward");
    }
    String[] categories = {"Java", "SQL", "DSA"};
    String[] difficulties = {"Easy", "Medium", "Hard"};
    String[] letters = {"A", "B", "C", "D"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Question - CodeQuest Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container" style="max-width: 760px;">
    <div class="card">
        <h2>&#10133; Add a New Mission</h2>

        <% if (added) { %>
            <div class="alert success">Question saved successfully!
                <a href="<%= request.getContextPath() %>/view-questions">View all questions</a></div>
        <% } %>
        <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

        <form action="<%= request.getContextPath() %>/add-question" method="post">
            <div class="form-group">
                <label for="title">Question Title</label>
                <input type="text" id="title" name="title" maxlength="100" required value="<%= HtmlUtil.escape(title) %>">
            </div>
            <div class="form-group">
                <label for="description">Question Description</label>
                <textarea id="description" name="description" required><%= HtmlUtil.escape(description) %></textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="category">Category</label>
                    <select id="category" name="category" required>
                        <option value="">-- choose --</option>
                        <% for (String c : categories) { %>
                            <option value="<%= c %>" <%= c.equals(category) ? "selected" : "" %>><%= c %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="difficulty">Difficulty</label>
                    <select id="difficulty" name="difficulty" required>
                        <option value="">-- choose --</option>
                        <% for (String d : difficulties) { %>
                            <option value="<%= d %>" <%= d.equals(difficulty) ? "selected" : "" %>><%= d %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="optionA">Option A</label>
                    <input type="text" id="optionA" name="optionA" maxlength="255" required value="<%= HtmlUtil.escape(optionA) %>">
                </div>
                <div class="form-group">
                    <label for="optionB">Option B</label>
                    <input type="text" id="optionB" name="optionB" maxlength="255" required value="<%= HtmlUtil.escape(optionB) %>">
                </div>
                <div class="form-group">
                    <label for="optionC">Option C</label>
                    <input type="text" id="optionC" name="optionC" maxlength="255" required value="<%= HtmlUtil.escape(optionC) %>">
                </div>
                <div class="form-group">
                    <label for="optionD">Option D</label>
                    <input type="text" id="optionD" name="optionD" maxlength="255" required value="<%= HtmlUtil.escape(optionD) %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="correctOption">Correct Answer</label>
                    <select id="correctOption" name="correctOption" required>
                        <option value="">-- choose --</option>
                        <% for (String l : letters) { %>
                            <option value="<%= l %>" <%= l.equals(correctOption) ? "selected" : "" %>>Option <%= l %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="xpReward">XP Reward</label>
                    <input type="number" id="xpReward" name="xpReward" min="1" max="500" value="<%= HtmlUtil.escape(xpReward) %>">
                </div>
            </div>

            <button type="submit" class="btn block">Save Question</button>
        </form>
    </div>
</div>
</body>
</html>
