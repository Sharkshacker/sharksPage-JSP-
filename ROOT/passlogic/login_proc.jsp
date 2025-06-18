<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page session="true" %>
<%@ include file="../db.jsp" %>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String sql = "SELECT * FROM user_table WHERE user_id = '" + username + "' AND user_password = '" + password + "'";

    Statement stmt = null;
    ResultSet rs = null;

    try {
        stmt = db_conn.createStatement();
        rs = stmt.executeQuery(sql);

        if (rs.next()) {
            session.setAttribute("idx", rs.getInt("user_idx"));
            session.setAttribute("username", rs.getString("user_id"));
            session.setAttribute("email", rs.getString("user_email"));
            session.setAttribute("phonenum", rs.getString("user_phonenum"));
            session.setAttribute("profile_image", rs.getString("profile_image") != null ? rs.getString("profile_image") : "img/profileshark.png");

            Cookie jsid = new Cookie("JSESSIONID", session.getId());
            jsid.setPath("/");
            jsid.setHttpOnly(false);
            response.addCookie(jsid);

            if ("admin".equals(rs.getString("user_id"))) {
%>
<script>
    alert('환영합니다! 관리자님!');
    location.href = '../index.jsp';
</script>
<%
            } else {
                response.sendRedirect("../index.jsp");
            }
        } else {
%>
<script>
    alert('로그인 실패! 다시 입력하세요.');
    history.back();
</script>
<%
        }
    } catch (Exception e) {
        out.println("DB 오류: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (db_conn != null) db_conn.close(); } catch (Exception e) {}
    }
%>
