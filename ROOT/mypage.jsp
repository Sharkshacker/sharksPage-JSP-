<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.UUID" %>
<%@ include file="db.jsp" %>
<%
    String username = (String) session.getAttribute("username");
    Integer userIdx = (Integer) session.getAttribute("idx");
    if (username == null || userIdx == null) {
%>
<script>
    alert('로그인 후 사용가능합니다.');
    window.location.href = 'passlogic/login.jsp';
</script>
<%
        return;
    }

    // CSRF 토큰 생성
    String csrf_token = UUID.randomUUID().toString().replace("-", "");
    session.setAttribute("csrf_token", csrf_token);
    

    String profileImage = session.getAttribute("profile_image") != null
        ? (String) session.getAttribute("profile_image")
        : "img/profileshark.png";
    String email = (String) session.getAttribute("email");
    String phonenum = (String) session.getAttribute("phonenum");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 마이페이지</title>
    <link rel="stylesheet" href="style.css">
    <link rel="icon" href="/img/sharks2.jpg" type="image/jpeg">
</head>
<body class="mypage">
<jsp:include page="nav.jsp" />
<div class="profile-box">
    <form method="POST" action="mypage_proc.jsp" enctype="multipart/form-data">
        <input type="hidden" name="removeImage" id="removeImage" value="0">
        <input type="hidden" name="csrf_token" value="<%= csrf_token %>">

        <div class="profile-img-change">
            <img src="<%= profileImage %>" alt="Profile Image" id="profileImage" class="profile-img">
            <div class="edit-icon" onclick="document.getElementById('imageUpload').click()">✏️</div>
        </div>

        <h2 style="text-align:center;margin:20px 0;">
            <%= username %>
        </h2>
        <p>프로필 이미지 권장 크기는 512x512 입니다.</p>
        <button type="button" onclick="setDefaultImage()">기본 이미지로 변경</button>
        <input
            type="file"
            id="imageUpload"
            name="profileImage"
            accept="image/*"
            style="display:none;"
            onchange="loadImage(event)">

        <div class="input-group">
            <label for="username">이름</label>
            <input
                type="text"
                id="username"
                name="username"
                value="<%= username %>"
                maxlength="30">
        </div>
        <div class="input-group">
            <label for="pw">비밀번호 변경</label>
            <input
                type="password"
                id="pw"
                name="pw"
                placeholder="변경할 비밀번호 입력">
        </div>
        <div class="input-group">
            <label for="email">Email</label>
            <input
                type="email"
                id="email"
                name="email"
                value="<%= email != null ? email : "" %>">
        </div>
        <div class="input-group">
            <label for="phonenum">PhoneNumber</label>
            <input
                type="text"
                id="phonenum"
                name="phonenum"
                value="<%= phonenum != null ? phonenum : "" %>">
        </div>
        <button type="submit">변경 사항 저장</button>
    </form>

<%
    if (!"admin".equals(username)) {
%>
    <form method="POST" action="user_delete.jsp" onsubmit="return confirm('정말 탈퇴하시겠습니까?');" style="margin-top:20px;">
        <input type="hidden" name="csrf_token" value="<%= csrf_token %>">
        <button type="submit" style="background-color:#e74c3c;">회원 탈퇴</button>
    </form>
<%
    }
%>
</div>
<script src="js/modal.js"></script>
<script src="js/mypage.js"></script>
</body>
</html>
