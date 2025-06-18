<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ include file="../db.jsp" %>


<%
    String username = (String) session.getAttribute("username");
    Integer userIdx = session.getAttribute("idx") != null ? (Integer) session.getAttribute("idx") : -1;

    if (username == null) {
%>
    <script>
        alert('로그인 후 이용해주세요.');
        location.href = '../passlogic/login.jsp';
    </script>
<%
        return;
    }

    String idParam = request.getParameter("id");
    int id = 0;
    try {
        id = Integer.parseInt(idParam);
    } catch (Exception e) {}

    if (id == 0) {
%>
    <script>
        alert('잘못된 접근입니다.');
        location.href = '../index.jsp';
    </script>
<%
        return;
    }

    Statement stmt = null;
    ResultSet rs = null;
    ResultSet userRs = null;
    try {
        stmt = db_conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM board_table WHERE board_idx = " + id);

        if (!rs.next()) {
%>
    <script>
        alert('존재하지 않는 게시글입니다.');
        location.href = '../index.jsp';
    </script>
<%
            return;
        }

        String title = rs.getString("board_title");
        String content = rs.getString("board_content");  
        int writerIdx = rs.getInt("user_idx");
        String date = rs.getString("board_date");
        int views = rs.getInt("board_views");
        int secret = rs.getInt("board_secret");
        String file = rs.getString("board_file");
        String originName = rs.getString("board_file_original_name");

        boolean isAuthor = (writerIdx == userIdx);
        boolean isAdmin = "admin".equals(username);

        

        // 조회수 증가
        stmt.executeUpdate("UPDATE board_table SET board_views = board_views + 1 WHERE board_idx = " + id);

        // 작성자 ID 가져오기
        userRs = stmt.executeQuery("SELECT user_id FROM user_table WHERE user_idx = " + writerIdx);
        String writerId = "";
        if (userRs.next()) {
            writerId = userRs.getString("user_id");
        }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 게시글</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
</head>
<body class="view-page">
    <jsp:include page="../nav.jsp" />

    <div class="view">
        <h2><%= title %></h2>
        <div class="user_info">
            <p><b>작성자</b> <%= writerId %> | <%= date %> | <b>조회수</b> <%= views %></p>
        </div>

        <hr>
        <div class="content">
            <%
                out.println(content);
            %>  
        </div>

        <% if (file != null && !file.isEmpty()) { %>
        <div class="attachment">
            <p>
                <b>첨부파일:</b>
                <a href="../userupload/<%= file %>" target="_blank">
                    <%= originName != null && !originName.isEmpty() ? originName : file %>
                </a>
                &nbsp;
                ( <a href="download.jsp?file=<%= java.net.URLEncoder.encode(file, "UTF-8") %>&origin=<%= java.net.URLEncoder.encode(originName, "UTF-8") %>">
                    다운로드
                  </a> )
            </p>
        </div>
        <% } %>

        <div class="viewButton">
            <ul>
                <li>
                    <button onclick="location.href='../index.jsp'">목록</button>
                </li>
                <% if (isAuthor || isAdmin) { %>
                <li>
                    <button onclick="location.href='modify.jsp?id=<%= id %>'">수정</button>
                </li>
                <li>
                    <button onclick="location.href='delete.jsp?id=<%= id %>'">삭제</button>
                </li>
                <% } %>
            </ul>
        </div>
    </div>

    <script src="../js/modal.js"></script>
</body>
</html>

<%
    } catch (Exception e) {
        out.println("DB 오류: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (userRs != null) userRs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (db_conn != null) db_conn.close(); } catch (Exception e) {}
    }
%>
