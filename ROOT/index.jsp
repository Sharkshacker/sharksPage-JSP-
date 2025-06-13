<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ include file="db.jsp" %>

<%
    String username = (String) session.getAttribute("username");
    if (username == null) {
%>
    <script>
        alert('로그인 후 사용 가능합니다.');
        window.location.href = 'passlogic/login.jsp';
    </script>
<%
        return;
    }

    String searchBy = request.getParameter("search_by");
    String query = request.getParameter("query");
    String sortBy = request.getParameter("sort_by");

    if (searchBy == null) searchBy = "title";
    if (query == null) query = "";
    if (sortBy == null) sortBy = "latest";

    String whereClause = "";
    if (!query.isEmpty()) {
        if ("title".equals(searchBy)) {
            whereClause = "WHERE board_title LIKE '%" + query + "%'";
        } else if ("number".equals(searchBy) && query.matches("\\d+")) {
            whereClause = "WHERE board_idx = " + query;
        }
    }

    // 관리자글 상단 정렬(공지)
    String orderBy = "ORDER BY notice_order ASC, board_idx DESC";
    if ("oldest".equals(sortBy)) orderBy = "ORDER BY notice_order ASC, board_idx ASC";
    else if ("views".equals(sortBy)) orderBy = "ORDER BY notice_order ASC, board_views DESC";

    String sql =
        "SELECT b.*, u.user_id, " +
        "CASE WHEN u.user_id = 'admin' THEN 1 ELSE 2 END AS notice_order " +
        "FROM board_table b " +
        "JOIN user_table u ON b.user_idx = u.user_idx " +
        whereClause + " " + orderBy;

    PreparedStatement stmt = db_conn.prepareStatement(sql);
    ResultSet rs = stmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 게시판</title>
    <link rel="stylesheet" href="style.css">
    <link rel="icon" href="/img/sharks2.jpg" type="image/jpeg">
</head>
<body>
    <jsp:include page="nav.jsp" />

    <div class="index">
        <h1>자유게시판</h1>

        <div class="search-bar">
            <form method="GET" action="index.jsp" class="search-form">
                <select name="search_by">
                    <option value="title" <%= "title".equals(searchBy) ? "selected" : "" %>>제목</option>
                    <option value="number" <%= "number".equals(searchBy) ? "selected" : "" %>>번호</option>
                </select>
                <select name="sort_by">
                    <option value="latest" <%= "latest".equals(sortBy) ? "selected" : "" %>>최신순</option>
                    <option value="oldest" <%= "oldest".equals(sortBy) ? "selected" : "" %>>오래된순</option>
                    <option value="views" <%= "views".equals(sortBy) ? "selected" : "" %>>조회수순</option>
                </select>
                <input type="text" name="query" placeholder="검색어 입력" value="<%= query %>">
                <input type="submit" value="검색">
            </form>
            <button class="write-button" onclick="location.href = 'board/write.jsp'">글쓰기</button>
        </div>

        <table>
            <tr>
                <th width="70">번호</th>
                <th width="500">제목</th>
                <th width="120">작성자</th>
                <th width="100">작성일</th>
                <th width="100">조회수</th>
            </tr>

            <%
                while (rs.next()) {
                    int idx = rs.getInt("board_idx");
                    String title = rs.getString("board_title");
                    String date = rs.getString("board_date");
                    int views = rs.getInt("board_views");
                    String author = rs.getString("user_id"); // JOIN 결과에서 바로 가져옴
                    int secret = rs.getInt("board_secret");

                    String displayTitle = title;
                    if (secret == 1) {
                        displayTitle = "<span style='color:#f15c6f;font-weight:bold'>[비밀글입니다]</span> ";
                    }
                    if ("admin".equals(author)) {
                        displayTitle = "<span style='color:#2a6bff;font-weight:bold'>[공지]</span> " + displayTitle;
                    }
            %>
            <tr>
                <td><%= idx %></td>
                <td><a href="board/view.jsp?id=<%= idx %>"><%= displayTitle %></a></td>
                <td><%= author %></td>
                <td><%= date %></td>
                <td><%= views %></td>
            </tr>
            <%
                }
                rs.close();
                stmt.close();
            %>
        </table>

        <div class="page">
            <jsp:include page="board/pagenation.jsp" />
        </div>
    </div>

    <script src="js/modal.js"></script>
</body>
</html>
