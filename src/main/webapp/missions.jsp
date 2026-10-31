<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.List, com.codequest.model.Mission, com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: students only ----
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?msg=loginRequired");
        return;
    }
    @SuppressWarnings("unchecked")
    List<Mission> missions = (List<Mission>) request.getAttribute("missions");
    if (missions == null) {
        // opened directly -> load data through MissionServlet
        response.sendRedirect("missions");
        return;
    }
    String error = (String) request.getAttribute("error");
    String selCat = (String) request.getAttribute("selectedCategory");
    String selDiff = (String) request.getAttribute("selectedDifficulty");
    String ctx = request.getContextPath();

    // messages sent back by SubmitAnswerServlet (redirect with ?msg=...)
    String msg = request.getParameter("msg");
    String msgText = null;
    if ("noAnswer".equals(msg)) msgText = "Please select an answer before submitting.";
    else if ("alreadyAttempted".equals(msg)) msgText = "You have already attempted that mission. Only one attempt per mission is allowed.";
    else if ("invalidMission".equals(msg)) msgText = "That mission does not exist.";
    else if ("dbError".equals(msg)) msgText = "Database error: your answer could not be saved. Please try again.";

    String[] cats = {"Java", "SQL", "DSA"};
    String[] diffs = {"Easy", "Medium", "Hard"};
    String diffQuery = selDiff != null ? "&difficulty=" + selDiff : "";
    String catQuery = selCat != null ? "&category=" + selCat : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Missions - CodeQuest</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container">
    <h1>&#127919; Programming Missions</h1>
    <p class="muted">Choose a mission, pick one answer and submit. You get <strong>one attempt</strong> per mission.</p><br>

    <% if (msgText != null) { %><div class="alert error"><%= msgText %></div><% } %>
    <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

    <!-- category filter -->
    <div class="filters">
        <span class="muted">Category:</span>
        <a class="<%= selCat == null ? "active" : "" %>" href="<%= ctx %>/missions?x=1<%= diffQuery %>">All</a>
        <% for (String c : cats) { %>
            <a class="<%= c.equals(selCat) ? "active" : "" %>" href="<%= ctx %>/missions?category=<%= c %><%= diffQuery %>"><%= c %></a>
        <% } %>
    </div>
    <!-- difficulty filter -->
    <div class="filters">
        <span class="muted">Difficulty:</span>
        <a class="<%= selDiff == null ? "active" : "" %>" href="<%= ctx %>/missions?x=1<%= catQuery %>">All</a>
        <% for (String d : diffs) { %>
            <a class="<%= d.equals(selDiff) ? "active" : "" %>" href="<%= ctx %>/missions?difficulty=<%= d %><%= catQuery %>"><%= d %></a>
        <% } %>
    </div>

    <% if (missions.isEmpty() && error == null) { %>
        <div class="alert info">No missions available for this selection yet. Please check back later.</div>
    <% } %>

    <%
        String currentCategory = "";
        for (Mission m : missions) {
            if (!m.getCategory().equals(currentCategory)) {
                currentCategory = m.getCategory();
    %>
        <h2 class="category-title"><%= HtmlUtil.escape(currentCategory) %> Missions</h2>
    <%      } %>

        <div class="card mission" id="mission-<%= m.getId() %>">
            <div class="meta">
                <span class="badge cat"><%= HtmlUtil.escape(m.getCategory()) %></span>
                <span class="badge <%= HtmlUtil.escape(m.getDifficulty()) %>"><%= HtmlUtil.escape(m.getDifficulty()) %></span>
                <span class="badge xp">+<%= m.getXpReward() %> XP</span>
                <% if (m.isAttempted()) { %>
                    <% if (m.isSolvedCorrectly()) { %>
                        <span class="badge done">&#10004; Completed</span>
                    <% } else { %>
                        <span class="badge fail">&#10008; Attempted</span>
                    <% } %>
                <% } %>
            </div>
            <h3><%= HtmlUtil.escape(m.getTitle()) %></h3>
            <p class="desc"><%= HtmlUtil.escape(m.getDescription()) %></p>

            <form action="<%= ctx %>/submit-answer" method="post">
                <input type="hidden" name="missionId" value="<%= m.getId() %>">
                <%
                    String[] opts = {m.getOptionA(), m.getOptionB(), m.getOptionC(), m.getOptionD()};
                    String[] labels = {"A", "B", "C", "D"};
                    for (int i = 0; i < 4; i++) {
                %>
                    <label class="option">
                        <input type="radio" name="answer" value="<%= HtmlUtil.escape(opts[i]) %>"
                               <%= m.isAttempted() ? "disabled" : "required" %>>
                        <strong><%= labels[i] %>.</strong> <%= HtmlUtil.escape(opts[i]) %>
                    </label>
                <% } %>
                <% if (m.isAttempted()) { %>
                    <button type="button" class="btn" disabled>Already Attempted</button>
                <% } else { %>
                    <button type="submit" class="btn">Submit Answer</button>
                <% } %>
            </form>
        </div>
    <% } %>
</div>
</body>
</html>
