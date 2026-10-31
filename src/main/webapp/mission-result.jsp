<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: students only ----
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=loginRequired");
        return;
    }
    if (request.getAttribute("correct") == null) {
        // opened directly without submitting an answer
        response.sendRedirect("missions");
        return;
    }
    boolean correct = (Boolean) request.getAttribute("correct");
    boolean levelUp = (Boolean) request.getAttribute("levelUp");
    String missionTitle = (String) request.getAttribute("missionTitle");
    String submittedAnswer = (String) request.getAttribute("submittedAnswer");
    String correctAnswer = (String) request.getAttribute("correctAnswer");
    int xpEarned = (Integer) request.getAttribute("xpEarned");
    int totalXp = (Integer) request.getAttribute("totalXp");
    int newLevel = (Integer) request.getAttribute("newLevel");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mission Result - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container" style="max-width: 640px;">
    <div class="card center <%= correct ? "result-correct" : "result-wrong" %>">
        <div class="result-icon"><%= correct ? "&#127881;" : "&#10060;" %></div>
        <h1><%= correct ? "Correct Answer!" : "Wrong Answer" %></h1>
        <p class="muted">Mission: <strong><%= HtmlUtil.escape(missionTitle) %></strong></p><br>

        <p>Your answer: <strong><%= HtmlUtil.escape(submittedAnswer) %></strong></p>
        <% if (!correct) { %>
            <p>Correct answer: <strong><%= HtmlUtil.escape(correctAnswer) %></strong></p>
            <p class="muted mt">No XP awarded this time. Keep practising &mdash; the next mission is waiting!</p>
        <% } else { %>
            <p class="mt"><span class="badge xp" style="font-size:1.1rem;">+<%= xpEarned %> XP</span></p>
        <% } %>

        <% if (levelUp) { %>
            <div class="alert success mt">&#11088; LEVEL UP! You are now Level <%= newLevel %>!</div>
        <% } %>

        <p class="mt">Total XP: <strong><%= totalXp %></strong> &nbsp;|&nbsp; Level: <strong><%= newLevel %></strong></p>
        <br>
        <a class="btn" href="<%= request.getContextPath() %>/missions">Next Mission</a>
        &nbsp;
        <a class="btn secondary" href="<%= request.getContextPath() %>/dashboard">My Dashboard</a>
    </div>
</div>
</body>
</html>
