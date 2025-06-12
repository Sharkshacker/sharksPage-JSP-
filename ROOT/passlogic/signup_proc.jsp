<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ include file="../db.jsp" %>

<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    String password_check = request.getParameter("password_check");
    String email = request.getParameter("email");
    String phonenum = request.getParameter("phonenum");

    if (!password.equals(password_check)) {
%>
    <script>
        alert('비밀번호가 일치하지 않습니다.');
        history.back();
    </script>
<%
        return;
    }

    // 중복 확인 (SQL Injection 취약)
    String checkSql = "SELECT * FROM user_table WHERE user_id = '" + username + "'";
    Statement stmt = null;
    ResultSet rs = null;

    try {
        stmt = db_conn.createStatement();
        rs = stmt.executeQuery(checkSql);

        if (rs.next()) {
%>
    <script>
        alert('이미 등록된 ID입니다. 로그인 페이지로 이동합니다.');
        location.href = 'login.jsp';
    </script>
<%
        } else {
            // 비밀번호 해시 없이 저장 (약한 인증정보)
            String insertSql = "INSERT INTO user_table (user_id, user_password, user_email, user_phonenum) " +
                               "VALUES ('" + username + "', '" + password + "', '" + email + "', '" + phonenum + "')";
            int result = stmt.executeUpdate(insertSql);

            if (result > 0) {
%>
    <script>
        alert('회원가입 성공!');
        location.href = 'login.jsp';
    </script>
<%
            } else {
                out.println("회원가입 실패: 데이터 삽입 오류");
            }
        }
    } catch (Exception e) {
        out.println("DB 오류: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (db_conn != null) db_conn.close(); } catch (Exception e) {}
    }
%>
