<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../db.jsp" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sharks - 계정 찾기</title>
        <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
        <link rel="stylesheet" href="find_style.css">
        <link rel="stylesheet" href="../style.css">
    </head>
    <body class="index-page">
        <nav class="navbar">
            <div class="nav-left">
                <a href="../index.jsp">Sharks</a>
            </div>
        </nav>
        <div class="find-menu-container">
            <a href="find_id.jsp" class="find-menu-button">🔍 아이디 찾기</a>
            <a href="find_pw.jsp" class="find-menu-button">🔐 비밀번호 재설정</a>
        </div>
        <script src="../js/modal.js"></script>
    </body>
</html>
