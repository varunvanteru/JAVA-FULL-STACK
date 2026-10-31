<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.codequest.util.DBConnection, com.codequest.util.HtmlUtil" %>
<%
    // ---- protect page: admins only ----
    if (session.getAttribute("adminId") == null) {
        response.sendRedirect("admin-login.jsp?msg=adminRequired");
        return;
    }
    String adminName = (String) session.getAttribute("adminUsername");

    // ---- ServletContext (JSP implicit object "application") ----
    String appName = application.getInitParameter("appName");
    Object adminLogins = application.getAttribute("adminLoginCount");

    // quick statistics
    int totalQuestions = 0, totalStudents = 0, totalSubmissions = 0;
    String error = null;
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT (SELECT COUNT(*) FROM missions), (SELECT COUNT(*) FROM users), (SELECT COUNT(*) FROM mission_submissions)");
         ResultSet rs = ps.executeQuery()) {
        if (rs.next()) {
            totalQuestions = rs.getInt(1);
            totalStudents = rs.getInt(2);
            totalSubmissions = rs.getInt(3);
        }
    } catch (SQLException e) {
        error = "Database error: could not load statistics. " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CodeQuest</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container">
    <h1>Admin Dashboard</h1>
    <p class="muted">Welcome, <strong><%= HtmlUtil.escape(adminName) %></strong> &mdash;
        manage the missions of <%= HtmlUtil.escape(appName) %>.
        (Admin logins since server start: <%= adminLogins == null ? 0 : adminLogins %>)</p><br>

    <% if (error != null) { %><div class="alert error"><%= HtmlUtil.escape(error) %></div><% } %>

    <div class="grid">
        <div class="card stat"><div class="value"><%= totalQuestions %></div><div class="label">Questions</div></div>
        <div class="card stat"><div class="value"><%= totalStudents %></div><div class="label">Registered Students</div></div>
        <div class="card stat"><div class="value"><%= totalSubmissions %></div><div class="label">Submissions</div></div>
    </div>

    <div class="grid">
        <a class="card feature" href="<%= request.getContextPath() %>/add-question.jsp">
            <div class="icon">&#10133;</div>
            <h3>Add Question</h3>
            <p class="muted">Create a new Java, SQL or DSA mission.</p>
        </a>
        <a class="card feature" href="<%= request.getContextPath() %>/view-questions">
            <div class="icon">&#128203;</div>
            <h3>View Questions</h3>
            <p class="muted">See all missions stored in the database.</p>
        </a>
        <a class="card feature" href="<%= request.getContextPath() %>/admin-logout">
            <div class="icon">&#128682;</div>
            <h3>Logout</h3>
            <p class="muted">End the admin session securely.</p>
        </a>
    </div>
</div>
</body>
</html>
