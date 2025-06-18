<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.util.regex.*, java.io.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ include file="db.jsp" %>
<%
    request.setCharacterEncoding("UTF-8");

    // ===== 이미지 검증 유틸리티 함수 =====
%>
<%! 
    private static final String[] BLOCKED_EXT = {
    "jspx", "php", "asp", "aspx", "exe", "bat", "sh", "js", "html", "htm", "phtml", "cgi"
    };
    private static final String[] ALLOWED_MIME = {"image/jpeg", "image/png", "image/gif", "image/bmp", "image/webp"};

    private boolean checkExtension(String filename) {
        if (filename == null) return false;
        String lower = filename.toLowerCase();
        for (String ext : BLOCKED_EXT) {
            if (lower.endsWith("." + ext)) return true;
        }
        return false;
    }
    private boolean checkMimeType(String mime) {
        if (mime == null) return false;
        for (String m : ALLOWED_MIME) {
            if (mime.equalsIgnoreCase(m)) return true;
        }
        return false;
    }
    private boolean checkMagicNumber(InputStream is) throws Exception {
        byte[] buf = new byte[8];
        int len = is.read(buf);
        if (len < 4) return false;
        // JPEG: FF D8 FF
        if (buf[0]==(byte)0xFF && buf[1]==(byte)0xD8 && buf[2]==(byte)0xFF) return true;
        // PNG: 89 50 4E 47
        if (buf[0]==(byte)0x89 && buf[1]==(byte)0x50 && buf[2]==(byte)0x4E && buf[3]==(byte)0x47) return true;
        // GIF: 47 49 46 38
        if (buf[0]==(byte)0x47 && buf[1]==(byte)0x49 && buf[2]==(byte)0x46 && buf[3]==(byte)0x38) return true;
        // BMP: 42 4D
        if (buf[0]==(byte)0x42 && buf[1]==(byte)0x4D) return true;
        // WebP: 52 49 46 46....57 45 42 50
        if (buf[0]==(byte)0x52 && buf[1]==(byte)0x49 && buf[2]==(byte)0x46 && buf[3]==(byte)0x46) return true;
        return false;
    }
%>
<%
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        return;
    }

    // CSRF 검증
    String sessionToken = (String) session.getAttribute("csrf_token");
    String formToken = null;
    String contentType = request.getContentType();
    if (contentType != null && contentType.toLowerCase().startsWith("multipart/")) {
        Part tokenPart = request.getPart("csrf_token");
        if (tokenPart != null) {
            BufferedReader reader = new BufferedReader(new InputStreamReader(tokenPart.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            formToken = sb.toString();
        }
    } else {
        formToken = request.getParameter("csrf_token");
    }
    if (sessionToken == null || formToken == null || !sessionToken.equals(formToken)) {
%>
        <script>
            alert('잘못된 접근입니다.');
            history.back();
        </script>
<%
        return;
    }
    session.removeAttribute("csrf_token");

    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String phoneNum = request.getParameter("phonenum");
    int idx = session.getAttribute("idx") != null ? Integer.parseInt(session.getAttribute("idx").toString()) : 0;
    String removeFlag = request.getParameter("removeImage") != null ? request.getParameter("removeImage") : "0";

    // ★ 이름 중복 체크 ★
    String dupSql = "SELECT COUNT(*) AS cnt FROM user_table WHERE user_id = ? AND user_idx != ?";
    PreparedStatement dupStmt = db_conn.prepareStatement(dupSql);
    dupStmt.setString(1, username);
    dupStmt.setInt(2, idx);
    ResultSet dupRs = dupStmt.executeQuery();
    if (dupRs.next() && dupRs.getInt("cnt") > 0) {
%>
        <script>
            alert('이미 사용 중인 이름입니다.');
            history.back();
        </script>
<%
        return;
    }
    dupRs.close();
    dupStmt.close();

    // 유효성 검사
    if (username == null || username.trim().isEmpty()) {
%>
        <script>
            alert('이름(아이디) 칸을 비워둘 수 없습니다.');
            history.back();
        </script>
<%
        return;
    }
    if (email == null || !email.matches("^[\\w._%+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$")) {
%>
        <script>
            alert('이메일 형식이 맞지 않습니다.');
            history.back();
        </script>
<%
        return;
    }
    if (phoneNum == null || !phoneNum.matches("^\\d{3}-\\d{4}-\\d{4}$")) {
%>
        <script>
            alert('전화번호 형식이 맞지 않습니다.');
            history.back();
        </script>
<%
        return;
    }

    String sql = null;
    String profileImagePath = null;

    // 기존 이미지 제거 요청
    if ("1".equals(removeFlag)) {
        String oldProfileImage = (String) session.getAttribute("profile_image");
        if (oldProfileImage != null && !oldProfileImage.isEmpty()) {
            File imgFile = new File(application.getRealPath("/") + oldProfileImage);
            if (imgFile.exists()) {
                imgFile.delete();
            }
        }
        sql = "UPDATE user_table SET user_id = ?, user_email = ?, user_phonenum = ?, profile_image = NULL WHERE user_idx = ?";
    }
    // 새 이미지 업로드 (여기서 검증!)
    else if (request.getPart("profileImage") != null && request.getPart("profileImage").getSize() > 0) {
        Part imageFile = request.getPart("profileImage");
        String fileName = imageFile.getSubmittedFileName();

        // [1] 확장자 체크
        if (checkExtension(fileName)) {
%>
            <script>
                alert('이미지 파일만 업로드할 수 있습니다. (확장자)');
                history.back();
            </script>
<%
            return;
        }

        // [2] MIME 타입 체크
        String mimeType = imageFile.getContentType();
        if (!checkMimeType(mimeType)) {
%>
            <script>
                alert('이미지 파일만 업로드할 수 있습니다. (MIME)');
                history.back();
            </script>
<%
            return;
        }

        // [3] Magic number(시그니처) 체크
        InputStream imgIs = imageFile.getInputStream();
        if (!checkMagicNumber(imgIs)) {
            imgIs.close();
%>
            <script>
                alert('실제 이미지 파일만 업로드할 수 있습니다. (Magic Number)');
                history.back();
            </script>
<%
            return;
        }
        imgIs.close();

        String uploadDir = application.getRealPath("/") + "userupload/";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
        String uploadPath = uploadDir + fileName;
        imageFile.write(uploadPath);
        profileImagePath = "userupload/" + fileName;

        sql = "UPDATE user_table SET user_id = ?, user_email = ?, user_phonenum = ?, profile_image = ? WHERE user_idx = ?";
    }
    // 비밀번호 변경
    else {
        String pw = request.getParameter("pw");
        if (pw != null && !pw.isEmpty()) {
            sql = "UPDATE user_table SET user_id = ?, user_email = ?, user_phonenum = ?, user_password = ? WHERE user_idx = ?";
        } else {
            sql = "UPDATE user_table SET user_id = ?, user_email = ?, user_phonenum = ? WHERE user_idx = ?";
        }
    }

    PreparedStatement pstmt = null;
    int result = 0;
    try {
        if ("1".equals(removeFlag)) {
            pstmt = db_conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, email);
            pstmt.setString(3, phoneNum);
            pstmt.setInt(4, idx);
        } else if (profileImagePath != null) {
            pstmt = db_conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, email);
            pstmt.setString(3, phoneNum);
            pstmt.setString(4, profileImagePath);
            pstmt.setInt(5, idx);
        } else {
            String pw = request.getParameter("pw");
            if (pw != null && !pw.isEmpty()) {
                pstmt = db_conn.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.setString(2, email);
                pstmt.setString(3, phoneNum);
                pstmt.setString(4, pw);
                pstmt.setInt(5, idx);
            } else {
                pstmt = db_conn.prepareStatement(sql);
                pstmt.setString(1, username);
                pstmt.setString(2, email);
                pstmt.setString(3, phoneNum);
                pstmt.setInt(4, idx);
            }
        }
        result = pstmt.executeUpdate();
    } finally {
        if (pstmt != null) pstmt.close();
    }

    if (result > 0) {
        // 세션 갱신
        session.setAttribute("username", username);
        session.setAttribute("email", email);
        session.setAttribute("phonenum", phoneNum);
        if ("1".equals(removeFlag)) {
            session.removeAttribute("profile_image");
        } else if (profileImagePath != null) {
            session.setAttribute("profile_image", profileImagePath);
        }
%>
        <script>
            alert('변경 사항을 저장하였습니다.');
            window.location.href = 'mypage.jsp';
        </script>
<%
    } else {
%>
        <script>
            alert('변경 사항 저장 중 오류가 발생하였습니다.');
            history.back();
        </script>
<%
    }
%>
