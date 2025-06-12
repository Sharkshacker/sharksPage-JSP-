<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Sharks - 아이디 찾기</title>
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
            <h2>🔍 아이디 찾기</h2>
            <form method="POST" action="find_id_proc.jsp" class="find-form">
                <label for="email">가입한 이메일</label>
                <input type="email" id="email" name="email" required placeholder="example@domain.com">

                <label for="phonenum">전화번호</label>
                <input type="text" id="phonenum" name="phonenum" required placeholder="010-1234-5678">

                <input type="submit" value="아이디 찾기">
            </form>
        </div>

        <script src="../js/modal.js"></script>
    </body>
</html>
