<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../db.jsp" %>
<%
    // 세션에서 관리자 확인
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equals(username)) {
%>
<script>
    alert('관리자만 접근 가능합니다.');
    location.href = '../index.jsp';
</script>
<%
        return;
    }

    // GET 파라미터에서 uid
    int uid = 0;
    try { uid = Integer.parseInt(request.getParameter("uid")); } catch (Exception e) {}
    if (uid < 1) {
%>
<script>
    alert('잘못된 접근입니다.');
    history.back();
</script>
<%
        return;
    }

    // 회원 아이디 구하기
    Statement stmt = db_conn.createStatement();
    ResultSet nameRes = stmt.executeQuery("SELECT user_id FROM user_table WHERE user_idx = " + uid);
    String userName = "";
    if (nameRes.next()) userName = nameRes.getString("user_id");

    // 게시글 목록 조회
    ResultSet postRes = stmt.executeQuery(
        "SELECT board_idx, board_title, board_date FROM board_table " +
        "WHERE user_idx = " + uid + " ORDER BY board_date DESC"
    );
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지 - <%= userName %> 게시글</title>
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="admin_style.css">
</head>
<body class="index-page">
<jsp:include page="../nav.jsp" />

<div class="main-box">
    <h1><%= userName %> 님의 게시글</h1>
    <table class="index">
        <thead>
            <tr>
                <th>제목</th>
                <th>작성일</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (postRes.next()) {
                int board_idx = postRes.getInt("board_idx");
                String board_title = postRes.getString("board_title");
                String board_date = postRes.getString("board_date");
        %>
            <tr>
                <td>
                    <a href="../board/view.jsp?id=<%= board_idx %>">
                        <%= board_title %>
                    </a>
                </td>
                <td><%= board_date %></td>
            </tr>
        <%
            }
            postRes.close();
            stmt.close();
        %>
        </tbody>
    </table>
</div>
<script src="../js/modal.js"></script>
</body>
</html>
