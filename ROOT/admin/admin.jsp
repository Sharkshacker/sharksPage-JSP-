<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../db.jsp" %>
<%
    // 인증 우회 취약점: admin=1 파라미터로 우회 허용
    String username = (String) session.getAttribute("username");
    String adminBypass = request.getParameter("admin");

    if ((username == null || !"admin".equals(username)) && !"1".equals(adminBypass)) {
%>
<script>
    alert('관리자만 접근 가능합니다.');
    location.href = '../index.jsp';
</script>
<%
        return;
    }

    String csrfToken = (String) session.getAttribute("csrf_token");
    if (csrfToken == null) {
        csrfToken = UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }

    // page 예약어 피하기 (adminPage 사용)
    int adminPage = 1;
    String param = request.getParameter("page");
    if (param != null) {
        try { adminPage = Math.max(1, Integer.parseInt(param)); } catch (Exception e) {}
    }
    int limit = 10;
    int offset = (adminPage - 1) * limit;

    // 회원 목록, 총 회원 수 쿼리
    Statement stmt = db_conn.createStatement();
    ResultSet totalRes = stmt.executeQuery("SELECT COUNT(*) AS cnt FROM user_table");
    totalRes.next();
    int totalCnt = totalRes.getInt("cnt");
    int totalPages = (int) Math.ceil((double) totalCnt / limit);

    ResultSet userRes = stmt.executeQuery(
        "SELECT user_idx, user_id, user_email, user_phonenum " +
        "FROM user_table ORDER BY user_idx ASC " +
        "LIMIT " + offset + ", " + limit
    );
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지 - 회원 관리</title>
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="admin_style.css">
</head>
<body class="index-page">
<jsp:include page="../nav.jsp" />

<div class="main-box">
    <h1>회원 목록</h1>

    <form method="GET" action="import_user.jsp" class="import-form">
        <button type="submit" class="btn-import">회원 대량 등록</button>
    </form>

    <form method="POST" action="cleanup.jsp" class="cleanup-form"
          onsubmit="return confirm('DB와 userupload 폴더를 비교하여 사용되지 않는 파일을 모두 삭제합니다.\n진행하시겠습니까?');">
        <button type="submit" class="btn-cleanup">파일 정리</button>
    </form>

    <table class="index">
        <thead>
        <tr>
            <th>번호</th>
            <th>아이디</th>
            <th>Email</th>
            <th>Phone</th>
            <th>수정</th>
            <th>게시글 수</th>
            <th>게시글 보기</th>
            <th>삭제</th>
        </tr>
        </thead>
        <tbody>
        <%
            while (userRes.next()) {
                int uid = userRes.getInt("user_idx");
                String id = userRes.getString("user_id");
                String email = userRes.getString("user_email");
                String phone = userRes.getString("user_phonenum");

                // 게시글 수 카운트용 Statement/ResultSet 따로!
                Statement cntStmt = db_conn.createStatement();
                ResultSet cntRes = cntStmt.executeQuery("SELECT COUNT(*) AS cnt FROM board_table WHERE user_idx = " + uid);
                int postCnt = 0;
                if (cntRes.next()) {
                    postCnt = cntRes.getInt("cnt");
                }
                cntRes.close();
                cntStmt.close();
        %>
        <tr>
            <td><%= uid %></td>
            <td><%= id %></td>
            <td><%= email %></td>
            <td><%= phone %></td>
            <td><a href="edit_user.jsp?uid=<%= uid %>">수정</a></td>
            <td><%= postCnt %></td>
            <td><a href="user_posts.jsp?uid=<%= uid %>">보기</a></td>
            <td>
                <% if ("admin".equals(id)) { %>
                    <button class="btn-delete" disabled>삭제</button>
                <% } else { %>
                    <form method="POST" action="../user_delete.jsp"
                          onsubmit="return confirm('정말 삭제하시겠습니까?');" style="margin:0;">
                        <input type="hidden" name="uid" value="<%= uid %>">
                        <input type="hidden" name="csrf_token" value="<%= csrfToken %>">
                        <button type="submit" class="btn-delete">삭제</button>
                    </form>
                <% } %>
            </td>
        </tr>
        <%
            }
            userRes.close();
            stmt.close();
        %>
        </tbody>
    </table>

    <div class="page">
        <% for (int i = 1; i <= totalPages; i++) { %>
            <a href="?page=<%= i %>"><%= i %></a>
        <% } %>
    </div>
</div>

<script src="../js/modal.js"></script>
</body>
</html>
