<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.codequest.util.DBConnection, com.codequest.util.HtmlUtil" %>
<%
    // Module 11 - Global Leaderboard
    // Data is read live from MySQL every time the page is loaded / refreshed,
    // so new XP appears automatically.
    String ctx = request.getContextPath();
    Object myIdObj = session.getAttribute("userId");
    int myId = myIdObj == null ? -1 : (Integer) myIdObj;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leaderboard - CodeQuest</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
<%@ include file="/WEB-INF/navbar.jsp" %>

<div class="container">
    <div class="card">
        <h2>&#127942; Global Leaderboard</h2>
        <p class="muted">Players ranked by total XP. Refresh the page to see the latest scores.</p><br>
<%
    String sql = "SELECT u.id, u.username, u.player_level, u.total_xp, "
               + "COUNT(s.id) AS completed "
               + "FROM users u "
               + "LEFT JOIN mission_submissions s ON s.user_id = u.id AND s.is_correct = TRUE "
               + "GROUP BY u.id, u.username, u.player_level, u.total_xp "
               + "ORDER BY u.total_xp DESC, completed DESC, u.username ASC";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        int rank = 0;
        while (rs.next()) {
            rank++;
            if (rank == 1) {
%>
        <table>
            <tr>
                <th>Rank</th>
                <th>Player</th>
                <th>Level</th>
                <th>Missions Completed</th>
                <th>Total XP</th>
            </tr>
<%
            }
            String medal;
            if (rank == 1) medal = "&#129351;";       // gold medal
            else if (rank == 2) medal = "&#129352;";  // silver medal
            else if (rank == 3) medal = "&#129353;";  // bronze medal
            else medal = "#" + rank;

            String rowClass = rank <= 3 ? "rank-" + rank : "";
            if (rs.getInt("id") == myId) rowClass += " me";
%>
            <tr class="<%= rowClass %>">
                <td class="rank"><%= medal %></td>
                <td><%= HtmlUtil.escape(rs.getString("username")) %><%= rs.getInt("id") == myId ? " <span class=\"badge xp\">You</span>" : "" %></td>
                <td>Level <%= rs.getInt("player_level") %></td>
                <td><%= rs.getInt("completed") %></td>
                <td><strong><%= rs.getInt("total_xp") %> XP</strong></td>
            </tr>
<%
        }
        if (rank == 0) {
%>
        <div class="alert info">No players yet. Be the first to <a href="<%= ctx %>/register.jsp">register</a> and claim the top spot!</div>
<%
        } else {
%>
        </table>
<%
        }
    } catch (SQLException e) {
%>
        <div class="alert error">Database error: could not load the leaderboard. <%= HtmlUtil.escape(e.getMessage()) %></div>
<%
    }
%>
    </div>
</div>
</body>
</html>
