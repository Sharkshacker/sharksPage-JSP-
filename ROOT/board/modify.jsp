<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*, javax.servlet.http.* , java.nio.file.Paths" %>
<%@ include file="../db.jsp" %>
<%
    // 취약: 로그인만 되어 있으면 누구나 수정 가능 (권한 인가 우회)
    String username = (String) session.getAttribute("username");
    if (username == null) {
%>
<script>
    alert('로그인 후 이용해주세요.');
    location.href = '../passlogic/login.jsp';
</script>
<%
    return;
    }

    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
%>
<script>
    alert('잘못된 접근입니다.');
    location.href = '../index.jsp';
</script>
<%
        return;
    }

    // 취약: 글 작성자 검증 생략 (권한 인가 우회)
    PreparedStatement ps = db_conn.prepareStatement("SELECT * FROM board_table WHERE board_idx = ?");
    ps.setInt(1, id);
    ResultSet board = ps.executeQuery();
    if (!board.next()) {
%>
<script>
    alert('존재하지 않는 게시글입니다.');
    location.href = '../index.jsp';
</script>
<%
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        boolean secret = "1".equals(request.getParameter("secret"));
        boolean deleteFile = "1".equals(request.getParameter("delete_file"));

        String board_file = board.getString("board_file");
        String board_file_original_name = board.getString("board_file_original_name");
        String uploadDir = application.getRealPath("/userupload/");

        if (deleteFile && board_file != null && !board_file.isEmpty()) {
            File oldFile = new File(uploadDir + File.separator + board_file);
            if (oldFile.exists()) oldFile.delete();
            board_file = "";
            board_file_original_name = "";
        }

        Part filePart = request.getPart("uploaded_file");
        if (filePart != null && filePart.getSize() > 0) {
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = originalName.substring(originalName.lastIndexOf('.') + 1);
            String newFileName = "file_" + System.currentTimeMillis() + "." + ext;
            File uploadedFile = new File(uploadDir, newFileName);
            filePart.write(uploadedFile.getAbsolutePath());

            board_file = newFileName;
            board_file_original_name = originalName;
        }

        // 취약: XSS 필터링 없음 (Stored XSS)
        PreparedStatement update = db_conn.prepareStatement(
            "UPDATE board_table SET board_title=?, board_content=?, board_file=?, board_file_original_name=?, board_secret=? WHERE board_idx=?"
        );
        update.setString(1, title);  // <script> 삽입 가능
        update.setString(2, content); // <script> 삽입 가능
        update.setString(3, board_file);
        update.setString(4, board_file_original_name);
        update.setBoolean(5, secret);
        update.setInt(6, id);
        update.executeUpdate();
%>
<script>
    alert('수정 완료되었습니다!');
    location.href = 'view.jsp?id=<%= id %>';
</script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 게시글 수정</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
</head>
<body>
<jsp:include page="../nav.jsp" />
<div class="write">
    <h1>글을 수정하세요.</h1>
    <hr/>
    <form method="POST" action="modify.jsp?id=<%= id %>" enctype="multipart/form-data">
        <table class="writeTable">
            <tr>
                <th width="50">제목</th>
                <td><input type="text" name="title" value="<%= board.getString("board_title") %>" required></td>
            </tr>
            <tr>
                <th>내용</th>
                <td><textarea name="content" rows="5" cols="40" required><%= board.getString("board_content") %></textarea></td>
            </tr>
            <tr>
                <th>파일 업로드</th>
                <td>
                    <input type="file" name="uploaded_file" />
                    <%
                        String currentFileName = board.getString("board_file_original_name");
                        if (currentFileName != null && !currentFileName.isEmpty()) {
                    %>
                        <br/><small>현재 파일: <%= currentFileName %></small>
                        <div>
                            <input type="checkbox" name="delete_file" value="1" id="delete_file_cb" />
                            <label for="delete_file_cb">기존 파일 삭제</label>
                        </div>
                    <% } %>
                </td>
            </tr>
            <tr>
                <th>비밀글</th>
                <td>
                    <label><input type="checkbox" name="secret" value="1" <%= board.getInt("board_secret") == 1 ? "checked" : "" %>> 비밀글</label>
                </td>
            </tr>
        </table>
        <ul>
            <li><input class="button" type="submit" value="수정 완료"></li>
            <li><button type="button" onclick="location.href='view.jsp?id=<%= id %>'">취소</button></li>
        </ul>
    </form>
</div>
<script src="../js/modal.js"></script>
</body>
</html>
