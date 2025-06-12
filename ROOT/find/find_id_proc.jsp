<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../db.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT user_id FROM user_table WHERE user_email = ? AND user_phonenum = ?";
        pstmt = db_conn.prepareStatement(sql);
        pstmt.setString(1, email);
        pstmt.setString(2, phonenum);

        rs = pstmt.executeQuery();

        if (rs.next()) {
            String foundId = rs.getString("user_id");
%>
            <script>
                alert("회원님의 아이디는 [<%= foundId %>] 입니다.");
                location.href = "find_account.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("입력하신 정보가 일치하지 않습니다. 다시 한 번 확인해주세요.");
                history.back();
            </script>
<%
        }

    } catch (Exception e) {
%>
        <script>
            alert("오류가 발생했습니다. 다시 시도해주세요.");
            history.back();
        </script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception ignore) {}
    }
%>
