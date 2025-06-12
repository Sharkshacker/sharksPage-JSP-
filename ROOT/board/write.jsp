<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*, java.nio.file.*, java.io.*, java.util.UUID" %>
<%@ page import="java.net.URL, java.net.HttpURLConnection" %>
<%@ include file="../db.jsp" %>

<%
    String username = (String) session.getAttribute("username");
    Integer userIdxObj = (Integer) session.getAttribute("idx");

    if (username == null || userIdxObj == null) {
%>
    <script>
        alert('로그인 후 사용 가능합니다.');
        location.href = '../passlogic/login.jsp';
    </script>
<%
        return;
    }

    int userIdx = userIdxObj;

    String imgUrl = request.getParameter("img_url");
    String previewHtml = "";
    if (imgUrl != null && !imgUrl.isEmpty()) {
        boolean isCodeInjection = false;
        // 🔥 JSP 파싱 방지: 특수문자는 String 변수로 빼서 비교!
        String startTag = "<" + "%";
        String endTag = "%" + ">";
        if (imgUrl.trim().startsWith(startTag) && imgUrl.trim().endsWith(endTag)) {
            isCodeInjection = true;
        }
        if (isCodeInjection) {
            // SSTI: 입력값을 JSP 코드로 임시 파일 생성 후 include
            String uploadDir = application.getRealPath("/preview_tmp/");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String tempFile = "ssti_" + UUID.randomUUID().toString().replace("-", "") + ".jsp";
            String tempPath = uploadDir + File.separator + tempFile;

            PrintWriter writer = null;
            try {
                writer = new PrintWriter(new FileOutputStream(tempPath));
                writer.print(imgUrl); // 사용자 입력(JSP 코드) 저장
            } catch (Exception e) {
                tempFile = null;
            } finally {
                if (writer != null) writer.close();
            }

            if (tempFile != null) {
                String incPath = "/preview_tmp/" + tempFile;
                try {
                    previewHtml = "<b>코드 실행 결과:</b><br>";
                    RequestDispatcher rd = request.getRequestDispatcher(incPath);
                    rd.include(request, response);
                } catch (Exception e) {
                    previewHtml += "<span style='color:red'>실행 오류: " + e.getMessage() + "</span>";
                }
            } else {
                previewHtml = "<span style='color:red'>임시 파일 생성 실패</span>";
            }
        } else {
            // 원래 SSRF/이미지 미리보기 기능
            try {
                URL u = new URL(imgUrl);
                HttpURLConnection conn = (HttpURLConnection) u.openConnection();
                conn.setConnectTimeout(3000);
                conn.setReadTimeout(3000);
                conn.setRequestMethod("GET");
                conn.connect();
                String contentType = conn.getContentType();

                if (contentType != null && contentType.startsWith("image/")) {
                    previewHtml = "<img src='" + imgUrl + "' style='max-width:300px;border:2px solid #aaa;'>";
                } else {
                    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                    StringBuilder sb = new StringBuilder();
                    String inputLine;
                    int maxLen = 4096;
                    int totalLen = 0;
                    while ((inputLine = in.readLine()) != null && totalLen < maxLen) {
                        sb.append(inputLine).append("\n");
                        totalLen += inputLine.length();
                    }
                    in.close();
                    previewHtml = "<pre style='background:#222;color:#eaffef;padding:12px;border-radius:7px;max-width:600px;max-height:180px;overflow:auto;'>" +
                            sb.toString() + "</pre>";
                }
            } catch (Exception e) {
                previewHtml = "<span style='color:red'>요청 실패: " + e.getMessage() + "</span>";
            }
        }
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String secret = request.getParameter("secret") != null ? "1" : "0";
        String boardFile = "";
        String boardFileOriginalName = "";

        Part filePart = null;
        try { filePart = request.getPart("uploaded_file"); } catch (Exception e) {}
        if (filePart != null && filePart.getSize() > 0) {
            String uploadDir = request.getServletContext().getRealPath("/userupload");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int idx = originalName.lastIndexOf(".");
            if (idx != -1) ext = originalName.substring(idx + 1);

            String newFileName = "file_" + UUID.randomUUID().toString().replace("-", "") + (ext.isEmpty() ? "" : "." + ext);
            String uploadPath = uploadDir + File.separator + newFileName;

            try (InputStream input = filePart.getInputStream();
                 OutputStream fileout = new FileOutputStream(uploadPath)) {
                byte[] buffer = new byte[8192];
                int len;
                while ((len = input.read(buffer)) > 0) fileout.write(buffer, 0, len);
                boardFile = newFileName;
                boardFileOriginalName = originalName;
            } catch (Exception e) {
%>
    <script>
        alert('파일 업로드 실패: <%= e.getMessage() %>');
        history.back();
    </script>
<%
                return;
            }
        }

        String insertSql = "INSERT INTO board_table (board_title, board_content, user_idx, board_file, board_file_original_name, board_secret) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement pstmt = db_conn.prepareStatement(insertSql);
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, userIdx);
            pstmt.setString(4, boardFile);
            pstmt.setString(5, boardFileOriginalName);
            pstmt.setInt(6, Integer.parseInt(secret));
            pstmt.executeUpdate();
            pstmt.close();
%>
    <script>
        alert('작성 완료되었습니다!');
        location.href = '../index.jsp';
    </script>
<%
            return;
        } catch (Exception e) {
            out.println("DB 오류: " + e.getMessage());
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sharks - 게시글 작성</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
</head>
<body>
    <jsp:include page="../nav.jsp" />
    <div class="write">
        <h1>글을 작성하세요.</h1>
        <hr/>
        <table class="writeTable">
            <tr>
                <th style="width:110px;">미리보기</th>
                <td>
                    <form method="GET" action="write.jsp" style="margin-bottom:0; display:flex; gap:8px; align-items:center;">
                        <input type="text" name="img_url" placeholder="http://example.com/test.png"
                                style="flex:1; min-width:220px; padding:10px; border-radius:8px; border:1px solid #b5dbe7; font-size:1em;"
                                value="<%= request.getParameter("img_url") != null ? request.getParameter("img_url") : "" %>">
                        <button type="submit"
                            style="padding:8px 18px; border-radius:8px; background:#aae0fa; color:#232f3e; border:none; font-weight:600; font-size:1em; cursor:pointer;">
                        미리보기
                    </button>
                    </form>
                    <div style="margin-top:12px;">
                        <%= previewHtml %>
                    </div>
                </td>
            </tr>
        </table>
        <form method="POST" action="write.jsp" enctype="multipart/form-data">
            <table class="writeTable">
                <tr>
                    <th width="50">제목</th>
                    <td><input type="text" name="title" placeholder="제목을 입력하세요." required></td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td><textarea name="content" rows="5" cols="40" placeholder="내용을 입력하세요." required></textarea></td>
                </tr>
                <tr>
                    <th>파일 업로드</th>
                    <td><input type="file" name="uploaded_file"></td>
                </tr>
                <tr>
                    <th>비밀글</th>
                    <td>
                        <label>
                            <input type="checkbox" name="secret" value="1"> 비밀글
                        </label>
                    </td>
                </tr>
            </table>
            <ul>
                <li><input class="button" type="submit" value="작성 완료"></li>
                <li><button type="button" onclick="location.href='../index.jsp'">취소</button></li>
            </ul>
        </form>
    </div>
    <script src="../js/modal.js"></script>
</body>
</html>
