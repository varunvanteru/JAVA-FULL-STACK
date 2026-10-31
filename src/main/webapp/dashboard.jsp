<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: students only ----
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=loginRequired");
        return;
    }
    String error = (String) request.getAttribute("error");
    if (request.getAttribute("totalXp") == null && error == null) {
        // opened directly -> load data through DashboardServlet
        response.sendRedirect("dashboard");
        return;
    }
    String username = (String) request.getAttribute("username");
    int totalXp = request.getAttribute("totalXp") == null ? 0 : (Integer) request.getAttribute("totalXp");
    int level = request.getAttribute("level") == null ? 1 : (Integer) request.getAttribute("level");
    int correctCount = request.getAttribute("correctCount") == null ? 0 : (Integer) request.getAttribute("correctCount");
    int attemptedCount = request.getAttribute("attemptedCount") == null ? 0 : (Integer) request.getAttribute("attemptedCount");
    int totalMissions = request.getAttribute("totalMissions") == null ? 0 : (Integer) request.getAttribute("totalMissions");
    int xpIntoLevel = request.getAttribute("xpIntoLevel") == null ? 0 : (Integer) request.getAttribute("xpIntoLevel");
    int xpPerLevel = request.getAttribute("xpPerLevel") == null ? 100 : (Integer) request.getAttribute("xpPerLevel");
    int xpToNext = request.getAttribute("xpToNext") == null ? 100 : (Integer) request.getAttribute("xpToNext");
    int progressPercent = request.getAttribute("progressPercent") == null ? 0 : (Integer) request.getAttribute("progressPercent");
    Object memberSince = request.getAttribute("memberSince");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container">
    <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

    <h1>Welcome back, <%= HtmlUtil.escape(username != null ? username : session.getAttribute("username")) %>!</h1>
    <% if (memberSince != null) { %>
        <p class="muted">Player since <%= memberSince.toString().substring(0, 10) %></p>
    <% } %>
    <br>

    <div class="grid">
        <div class="card stat"><div class="value"><%= level %></div><div class="label">Current Level</div></div>
        <div class="card stat"><div class="value"><%= totalXp %></div><div class="label">Total XP</div></div>
        <div class="card stat"><div class="value"><%= correctCount %></div><div class="label">Missions Completed Correctly</div></div>
        <div class="card stat"><div class="value"><%= attemptedCount %> / <%= totalMissions %></div><div class="label">Missions Attempted</div></div>
    </div>

    <div class="card">
        <h3>Progress to Level <%= level + 1 %></h3>
        <div class="progress"><div class="bar" style="width: <%= progressPercent %>%;"></div></div>
        <p class="muted mt"><%= xpIntoLevel %> / <%= xpPerLevel %> XP &mdash;
            <strong><%= xpToNext %> XP</strong> more to reach the next level.</p>
    </div>

    <div class="center">
        <a class="btn" href="<%= request.getContextPath() %>/missions">Play Missions</a>
        &nbsp;
        <a class="btn secondary" href="<%= request.getContextPath() %>/leaderboard.jsp">View Leaderboard</a>
    </div>
</div>
</body>
</html>
