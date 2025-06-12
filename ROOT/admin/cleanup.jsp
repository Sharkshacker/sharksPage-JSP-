<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.io.*" %>
<%@ include file="../db.jsp" %>
<%
    // 관리자 확인
    String username = (String) session.getAttribute("username");
    if (username == null || !"admin".equals(username)) {
%>
<script>
    alert('관리자만 접근 가능합니다.');
    location.href = 'admin.jsp';
</script>
<%
        return;
    }

    List<String> used = new ArrayList<>();

    Statement stmt = db_conn.createStatement();
    ResultSet res = stmt.executeQuery(
        "SELECT profile_image FROM user_table " +
        "WHERE profile_image IS NOT NULL AND profile_image <> 'img/profileshark.png'"
    );
    while (res.next()) {
        used.add(res.getString("profile_image"));
    }
    res.close();

    res = stmt.executeQuery(
        "SELECT board_file FROM board_table " +
        "WHERE board_file IS NOT NULL AND board_file <> ''"
    );
    while (res.next()) {
        used.add("userupload/" + res.getString("board_file"));
    }
    res.close();
    stmt.close();

    String dirPath = application.getRealPath("/userupload");
    File dir = new File(dirPath);
    if (dir.exists() && dir.isDirectory()) {
        File[] files = dir.listFiles();
        if (files != null) {
            for (File file : files) {
                String rel = "userupload/" + file.getName();
                if (!used.contains(rel) && !used.contains(file.getAbsolutePath())) {
                    file.delete();
                }
            }
        }
    }
%>
<script>
    alert('사용되지 않는 파일 정리를 완료했습니다.');
    location.href = 'admin.jsp';
</script>
