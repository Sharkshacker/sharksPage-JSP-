<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 회원가입</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
</head>
<body class="signup-page">
    <jsp:include page="../nav.jsp" />

    <div class="signup-box">
        <h2>Sign Up</h2>
        <form action="signup_proc.jsp" method="POST">
            <div class="input-group">
                <label for="username">ID</label>
                <input type="text" id="username" name="username" placeholder="Enter Your ID" required>
            </div>
            <div class="input-group">
                <label for="password">PW</label>
                <input type="password" id="password" name="password" placeholder="Enter Your Password" required>
            </div>
            <div class="input-group">
                <label for="password_check">Check the PW</label>
                <input type="password" id="password_check" name="password_check" placeholder="Re-Enter Your Password" required>
            </div>
            <div class="input-group">
                <label for="email">Your Email</label>
                <input type="text" id="email" name="email" placeholder="ex) aaa@example.com" required>
            </div>
            <div class="input-group">
                <label for="phonenum">Your Phone Number</label>
                <input type="text" id="phonenum" name="phonenum" placeholder="ex) 000-0000-0000" required>
            </div>
            <button type="submit">Sign Up</button>
        </form>
    </div>
</body>
</html>
