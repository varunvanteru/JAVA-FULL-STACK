<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard");
        return;
    }
    String error = (String) request.getAttribute("error");
    String identifier = (String) request.getAttribute("identifier");

    // ---- Cookie demo: pre-fill the username saved by "Remember me" ----
    boolean remembered = false;
    if (identifier == null) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("cq_remember_user".equals(c.getName())) {
                    identifier = c.getValue();
                    remembered = true;
                }
            }
        }
    }

    String msg = request.getParameter("msg");
    String info = null;
    String success = null;
    if ("registered".equals(msg)) {
        success = "Registration successful! Please log in to start your quest.";
    } else if ("loggedout".equals(msg)) {
        success = "You have been logged out successfully.";
    } else if ("loginRequired".equals(msg)) {
        info = "Please log in as a student to access that page.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container narrow">
    <div class="card">
        <h2>Student Login</h2>

        <% if (success != null) { %><div class="alert success"><%= success %></div><% } %>
        <% if (info != null) { %><div class="alert info"><%= info %></div><% } %>
        <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

        <form action="<%= request.getContextPath() %>/login" method="post">
            <div class="form-group">
                <label for="identifier">Username or Email</label>
                <input type="text" id="identifier" name="identifier" required
                       value="<%= HtmlUtil.escape(identifier) %>">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label class="checkbox">
                    <input type="checkbox" name="remember" <%= remembered ? "checked" : "" %>> Remember my username
                </label>
            </div>
            <button type="submit" class="btn block">Log In</button>
        </form>
        <p class="center mt muted">New here? <a href="<%= request.getContextPath() %>/register.jsp">Create an account</a></p>
    </div>
</div>
</body>
</html>
