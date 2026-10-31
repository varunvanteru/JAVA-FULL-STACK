<%-- Common navigation bar, included in every JSP with:
     <%@ include file="/WEB-INF/navbar.jsp" %>
     It lives in WEB-INF so it cannot be opened directly in the browser. --%>
<%
    String navCtx = request.getContextPath();
    boolean navStudent = session.getAttribute("userId") != null;
    boolean navAdmin = session.getAttribute("adminId") != null;
%>
<header class="navbar">
    <a class="brand" href="<%= navCtx %>/index.html">&#9876; Code<span>Quest</span></a>
    <nav>
        <a href="<%= navCtx %>/index.html">Home</a>
        <% if (navAdmin) { %>
            <a href="<%= navCtx %>/admin-dashboard.jsp">Admin Dashboard</a>
            <a href="<%= navCtx %>/add-question.jsp">Add Question</a>
            <a href="<%= navCtx %>/view-questions">View Questions</a>
            <a href="<%= navCtx %>/leaderboard.jsp">Leaderboard</a>
            <a class="nav-btn" href="<%= navCtx %>/admin-logout">Logout (<%= com.codequest.util.HtmlUtil.escape(session.getAttribute("adminUsername")) %>)</a>
        <% } else if (navStudent) { %>
            <a href="<%= navCtx %>/dashboard">Dashboard</a>
            <a href="<%= navCtx %>/missions">Missions</a>
            <a href="<%= navCtx %>/leaderboard.jsp">Leaderboard</a>
            <a class="nav-btn" href="<%= navCtx %>/logout">Logout (<%= com.codequest.util.HtmlUtil.escape(session.getAttribute("username")) %>)</a>
        <% } else { %>
            <a href="<%= navCtx %>/missions">Missions</a>
            <a href="<%= navCtx %>/leaderboard.jsp">Leaderboard</a>
            <a href="<%= navCtx %>/register.jsp">Register</a>
            <a href="<%= navCtx %>/login.jsp">Student Login</a>
            <a class="nav-btn" href="<%= navCtx %>/admin-login.jsp">Admin Login</a>
        <% } %>
    </nav>
</header>
