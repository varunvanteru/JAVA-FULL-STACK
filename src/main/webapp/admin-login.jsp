<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.codequest.util.HtmlUtil" %>
<%
    if (session.getAttribute("adminId") != null) {
        response.sendRedirect("admin-dashboard.jsp");
        return;
    }
    String error = (String) request.getAttribute("error");
    String username = (String) request.getAttribute("username");

    String msg = request.getParameter("msg");
    String info = null;
    if ("loggedout".equals(msg)) {
        info = "Admin logged out successfully.";
    } else if ("adminRequired".equals(msg)) {
        info = "Admin access only. Please log in as an administrator.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container narrow">
    <div class="card">
        <h2>&#128737; Admin Login</h2>

        <% if (info != null) { %><div class="alert info"><%= info %></div><% } %>
        <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

        <form action="<%= request.getContextPath() %>/admin-login" method="post">
            <div class="form-group">
                <label for="username">Admin Username</label>
                <input type="text" id="username" name="username" required
                       value="<%= HtmlUtil.escape(username) %>">
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="btn block">Log In as Admin</button>
        </form>
    </div>
</div>
</body>
</html>
