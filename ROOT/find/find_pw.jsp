<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>비밀번호 재설정 - Sharks</title>
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
        <div class="find-container">
            <h2>🔐 비밀번호 재설정</h2>
            <form method="POST" action="find_pw_proc.jsp" class="find-form">
                <label for="userid">아이디</label>
                <input type="text" id="userid" name="userid" required placeholder="아이디 입력">
                <label for="email">가입한 이메일</label>
                <input type="email" id="email" name="email" required placeholder="example@domain.com">
                <label for="phonenum">전화번호</label>
                <input type="text" id="phonenum" name="phonenum" required placeholder="010-1234-5678">
                <input type="submit" value="임시 비밀번호 발급">
            </form>
        </div>

        <script src="../js/modal.js"></script>
        </body>
</html>
