<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.* , java.util.UUID" %>
<%@ include file="../db.jsp" %>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("userid");
    String email = request.getParameter("email");
    String phone = request.getParameter("phonenum");

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT * FROM user_table WHERE user_id = ? AND user_email = ? AND user_phonenum = ?";
        pstmt = db_conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, email);
        pstmt.setString(3, phone);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 사용자 정보 일치 → 임시 비밀번호 생성 및 업데이트
            String tempPw = UUID.randomUUID().toString().substring(0, 8); // 8자리 임시 비번
            String updateSql = "UPDATE user_table SET user_password = ? WHERE user_id = ?";
            PreparedStatement updateStmt = db_conn.prepareStatement(updateSql);
            updateStmt.setString(1, tempPw); // 해싱 없이 저장 (보안강화는 추후에)
            updateStmt.setString(2, userId);
            updateStmt.executeUpdate();
            updateStmt.close();
%>
<script>
    alert("임시 비밀번호는 [<%= tempPw %>] 입니다. 로그인 후 반드시 변경해주세요.");
    location.href = "../passlogic/login.jsp";
</script>
<%
        } else {
%>
<script>
    alert("입력한 정보가 일치하지 않습니다. 다시 확인해주세요.");
    history.back();
</script>
<%
        }
    } catch (Exception e) {
        out.println("에러 발생: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    }
%>
