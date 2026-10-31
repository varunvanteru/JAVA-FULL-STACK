<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    // already logged-in students go straight to their dashboard
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard");
        return;
    }
    String error = (String) request.getAttribute("error");
    String username = (String) request.getAttribute("username");
    String email = (String) request.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container narrow">
    <div class="card">
        <h2>Create Your Player</h2>
        <p class="muted">Every new player starts with 0 XP at Level 1.</p><br>

        <% if (error != null) { %>
            <div class="alert error"><%= HtmlUtil.escape(error) %></div>
        <% } %>

        <form action="<%= request.getContextPath() %>/register" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" maxlength="50" required
                       value="<%= HtmlUtil.escape(username) %>">
            </div>
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" maxlength="100" required
                       value="<%= HtmlUtil.escape(email) %>">
            </div>
            <div class="form-group">
                <label for="password">Password (min 6 characters)</label>
                <input type="password" id="password" name="password" minlength="6" required>
            </div>
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <input type="password" id="confirmPassword" name="confirmPassword" minlength="6" required>
            </div>
            <button type="submit" class="btn block">Register</button>
        </form>
        <p class="center mt muted">Already registered? <a href="<%= request.getContextPath() %>/login.jsp">Log in here</a></p>
    </div>
</div>
</body>
</html>
