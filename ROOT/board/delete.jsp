<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.io.*" %>
<%@ include file="../db.jsp" %>
<%
    // 게시글 ID 파라미터 처리
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

    if (id == 0) {
%>
<script>
    alert('잘못된 접근입니다.');
    location.href = '../index.jsp';
</script>
<%
        return;
    }

    // 파일 경로 불러오기
    String query = "SELECT board_file FROM board_table WHERE board_idx = ?";
    PreparedStatement ps = db_conn.prepareStatement(query);
    ps.setInt(1, id);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        String boardFile = rs.getString("board_file");
        if (boardFile != null && !boardFile.isEmpty()) {
            String uploadDir = application.getRealPath("../userupload/");
            File file = new File(uploadDir + File.separator + boardFile);
            if (file.exists()) file.delete();
        }
    }

    // 게시글 삭제
    PreparedStatement deletePs = db_conn.prepareStatement("DELETE FROM board_table WHERE board_idx = ?");
    deletePs.setInt(1, id);
    int deleted = deletePs.executeUpdate();

    if (deleted > 0) {
%>
<script>
    alert('삭제되었습니다.');
    window.location.href = '../index.jsp';
</script>
<%
    } else {
%>
<script>
    alert('삭제에 실패했습니다.');
    window.location.href = '../index.jsp';
</script>
<%
    }
%>
