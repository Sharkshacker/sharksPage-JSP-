<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%@ include file="../db.jsp" %>

<%
    String search_by = request.getParameter("search_by") != null ? request.getParameter("search_by") : "";
    String query = request.getParameter("query") != null ? request.getParameter("query") : "";
    String sort_by = request.getParameter("sort_by") != null ? request.getParameter("sort_by") : "latest";
    int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;

    int list_num = 10;
    int page_num = 10;

    // 관리자 user_idx 조회
    int adminIdx = -1;
    Statement stmt = db_conn.createStatement();
    ResultSet adminRs = stmt.executeQuery("SELECT user_idx FROM user_table WHERE user_id = 'admin'");
    if (adminRs.next()) {
        adminIdx = adminRs.getInt("user_idx");
    }

    // WHERE 절 구성
    String where_clause = "";
    if (!query.equals("")) {
        if (search_by.equals("title")) {
            query = query.replaceAll("'", "''"); // escape
            where_clause = "WHERE board_title LIKE '%" + query + "%'";
        } else if (search_by.equals("number")) {
            try {
                int numQuery = Integer.parseInt(query);
                where_clause = "WHERE board_idx = " + numQuery;
            } catch (NumberFormatException e) {}
        }
    }

    // 정렬 조건
    String order_field;
    switch (sort_by) {
        case "oldest": order_field = "board_idx ASC"; break;
        case "views": order_field = "board_views DESC"; break;
        default: order_field = "board_idx DESC"; break;
    }

    // 총 게시글 수
    ResultSet countRs = stmt.executeQuery("SELECT COUNT(*) AS total FROM board_table " + where_clause);
    countRs.next();
    int total = countRs.getInt("total");

    // 페이지 계산
    int total_page = (int)Math.ceil((double)total / list_num);
    int total_block = (int)Math.ceil((double)total_page / page_num);
    int now_block = (int)Math.ceil((double)page / page_num);

    int s_page = (now_block - 1) * page_num + 1;
    if (s_page < 1) s_page = 1;
    int e_page = now_block * page_num;
    if (e_page > total_page) e_page = total_page;

    int start = (page - 1) * list_num;
    String pin_clause = "(user_idx = " + adminIdx + ") DESC";

    // 게시글 조회
    ResultSet rs = stmt.executeQuery(
        "SELECT * FROM board_table " + where_clause +
        " ORDER BY " + pin_clause + ", " + order_field +
        " LIMIT " + start + ", " + list_num
    );
%>

<table class="index">
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>작성자</th>
        <th>작성일</th>
        <th>조회수</th>
    </tr>
<%
    boolean hasRows = false;
    while (rs.next()) {
        hasRows = true;
        int board_idx = rs.getInt("board_idx");
        String board_title = rs.getString("board_title");
        String board_date = rs.getString("board_date");
        int board_views = rs.getInt("board_views");

        // 작성자 이름 조회
        int writer_idx = rs.getInt("user_idx");
        String writer_name = "알 수 없음";
        ResultSet userRs = stmt.executeQuery("SELECT user_id FROM user_table WHERE user_idx = " + writer_idx);
        if (userRs.next()) writer_name = userRs.getString("user_id");
%>
    <tr>
        <td><%= board_idx %></td>
        <td><a href="board/view.jsp?id=<%= board_idx %>"><%= board_title %></a></td>
        <td><%= writer_name %></td>
        <td><%= board_date %></td>
        <td><%= board_views %></td>
    </tr>
<%
    }
    if (!hasRows) {
%>
    <tr><td colspan="5">검색 결과가 없습니다.</td></tr>
<%
    }

    // URL 파라미터 유지를 위한 문자열 생성
    String queryParam = "&query=" + URLEncoder.encode(query, "UTF-8")
                      + "&search_by=" + search_by
                      + "&sort_by=" + sort_by;

    // 페이징 변수 전달
    request.setAttribute("page", page);
    request.setAttribute("s_page", s_page);
    request.setAttribute("e_page", e_page);
    request.setAttribute("total_page", total_page);
    request.setAttribute("queryParam", queryParam);
%>
</table>

<jsp:include page="pagenation.jsp" />
