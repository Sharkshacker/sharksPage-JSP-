<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.UUID, java.util.List, java.util.ArrayList" %>

<%@ include file="../db.jsp" %>
<%
    // CSRF 토큰 생성
    String csrf = (String) session.getAttribute("csrf_token");
    if (csrf == null) {
        csrf = UUID.randomUUID().toString().replace("-", "");
        session.setAttribute("csrf_token", csrf);
    }

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

    int uid = 0;
    try {
        uid = Integer.parseInt(request.getParameter("uid"));
    } catch (Exception e) {
        uid = 0;
    }
    if (uid < 1) {
%>
<script>
    alert('잘못된 접근입니다.');
    location.href = 'admin.jsp';
</script>
<%
        return;
    }

    PreparedStatement ps = db_conn.prepareStatement("SELECT user_id, user_email, user_phonenum FROM user_table WHERE user_idx = ?");
    ps.setInt(1, uid);
    ResultSet rs = ps.executeQuery();
    if (!rs.next()) {
%>
<script>
    alert('존재하지 않는 회원입니다.');
    location.href = 'admin.jsp';
</script>
<%
        return;
    }
    String userId = rs.getString("user_id");
    String userEmail = rs.getString("user_email");
    String userPhone = rs.getString("user_phonenum");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newId = request.getParameter("username");
        String newEmail = request.getParameter("email");
        String newPhone = request.getParameter("phonenum");
        String newPw = request.getParameter("pw");

        if (!newEmail.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
%>
<script>
    alert('이메일 형식이 올바르지 않습니다.');
    history.back();
</script>
<%
            return;
        }
        if (!newPhone.matches("\\d{3}-\\d{4}-\\d{4}")) {
%>
<script>
    alert('전화번호 형식이 올바르지 않습니다.');
    history.back();
</script>
<%
            return;
        }

        List<String> fields = new ArrayList<>();
        fields.add("user_id = '" + newId + "'");
        fields.add("user_email = '" + newEmail + "'");
        fields.add("user_phonenum = '" + newPhone + "'");

        if (newPw != null && !newPw.trim().isEmpty()) {
            fields.add("user_password = '" + newPw + "'");
        }

        String sql = "UPDATE user_table SET " + String.join(", ", fields) + " WHERE user_idx = ?";
        PreparedStatement update = db_conn.prepareStatement(sql);
        update.setInt(1, uid);
        update.executeUpdate();
%>
<script>
    alert('수정 완료');
    location.href = 'admin.jsp';
</script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지 - 회원 수정</title>
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
    <link rel="stylesheet" href="../style.css">
    <link rel="stylesheet" href="admin_style.css">
</head>
<body class="index-page">
<jsp:include page="../nav.jsp" />
<div class="main-box">
    <h1>회원 정보 수정 (ID: <%= userId %>)</h1>
    <form method="POST" action="">
        <div class="input-group">
            <label for="username">이름</label>
            <input type="text" id="username" name="username" value="<%= userId %>" maxlength="30" required>
        </div>
        <div class="input-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" value="<%= userEmail %>" required>
        </div>
        <div class="input-group">
            <label for="phonenum">PhoneNumber</label>
            <input type="text" id="phonenum" name="phonenum" value="<%= userPhone %>" required>
        </div>
        <div class="input-group">
            <label for="pw">새 비밀번호 변경</label>
            <input type="password" id="pw" name="pw" placeholder="변경할 비밀번호 입력">
        </div>
        <button type="submit">저장</button>
    </form>
</div>
<script src="../js/modal.js"></script>
</body>
</html>
