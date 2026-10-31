<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, com.codequest.model.Mission, com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: admins only ----
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=adminRequired");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Mission> missions = (List<Mission>) request.getAttribute("missions");
    if (missions == null) {
        // opened directly -> go through the servlet so data is loaded
        response.sendRedirect("view-questions");
        return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Questions - CodeQuest Admin</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container">
    <div class="card">
        <h2>&#128203; Question Management</h2>
        <p class="muted">Total questions: <%= missions.size() %> &nbsp;|&nbsp;
            <a href="<%= request.getContextPath() %>/add-question.jsp">+ Add another question</a></p><br>

        <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

        <% if (missions.isEmpty() && error == null) { %>
            <div class="alert info">No questions created yet. Use "Add Question" to create the first mission.</div>
        <% } else if (!missions.isEmpty()) { %>
            <table>
                <tr>
                    <th>#</th>
                    <th>Title</th>
                    <th>Category</th>
                    <th>Difficulty</th>
                    <th>Correct Answer</th>
                    <th>XP Reward</th>
                </tr>
                <% int n = 1;
                   for (Mission m : missions) { %>
                <tr>
                    <td><%= n++ %></td>
                    <td><%= HtmlUtil.escape(m.getTitle()) %></td>
                    <td><span class="badge cat"><%= HtmlUtil.escape(m.getCategory()) %></span></td>
                    <td><span class="badge <%= HtmlUtil.escape(m.getDifficulty()) %>"><%= HtmlUtil.escape(m.getDifficulty()) %></span></td>
                    <td class="muted"><%= HtmlUtil.escape(m.getCorrectAnswer()) %></td>
                    <td><span class="badge xp"><%= m.getXpReward() %> XP</span></td>
                </tr>
                <% } %>
            </table>
        <% } %>
    </div>
</div>
</body>
</html>
