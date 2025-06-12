<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.xml.parsers.*, org.w3c.dom.*" %>
<%
    String result = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String xml = request.getParameter("xml");
        if (xml != null) {
            try {
                // [취약점!] 외부 엔티티 해제하지 않음
                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", false);
                dbf.setFeature("http://xml.org/sax/features/external-general-entities", true);
                dbf.setFeature("http://xml.org/sax/features/external-parameter-entities", true);

                DocumentBuilder db = dbf.newDocumentBuilder();
                Document doc = db.parse(new java.io.ByteArrayInputStream(xml.getBytes("UTF-8")));
                NodeList users = doc.getElementsByTagName("user");
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < users.getLength(); i++) {
                    Element user = (Element) users.item(i);
                    sb.append("ID: " + user.getElementsByTagName("id").item(0).getTextContent() + " / ");
                    sb.append("PW: " + user.getElementsByTagName("pw").item(0).getTextContent() + " / ");
                    sb.append("Email: " + user.getElementsByTagName("email").item(0).getTextContent() + "<br>");
                }
                result = sb.toString();
            } catch (Exception e) {
                String msg = e.getMessage();
                if (msg != null) {
                    if (msg.contains("processing instruction target matching")) {
                        result = "파싱 오류: \"<?xml ...?>\" 같은 XML 선언 구문이 허용되지 않습니다.";
                    } else if (msg.contains("Premature end of file")) {
                        result = "파싱 오류: XML 형식이 올바르지 않습니다. (파일 끝에서 예기치 않은 종료)";
                    } else if (msg.contains("is not allowed in prolog")) {
                        result = "파싱 오류: XML 시작 부분에 허용되지 않은 문자가 있습니다.";
                    } else if (msg.contains("Content is not allowed in prolog")) {
                        result = "파싱 오류: XML 시작 부분에 잘못된 내용이 포함되어 있습니다.";
                    } else if (msg.contains("Element type") && msg.contains("must be followed by either attribute specifications")) {
                        result = "파싱 오류: XML 태그 형식이 잘못되었습니다.";
                    } else if (msg.contains("The reference to entity") && msg.contains("must end with the ';' delimiter")) {
                        result = "파싱 오류: 엔티티 참조가 ';' 문자로 끝나야 합니다.";
                    } else if (msg.contains("External entity")) {
                        result = "파싱 오류: 외부 엔티티를 불러오는 과정에서 문제가 발생했습니다.";
                    } else {
                        // 그 밖의 예외는 영어로 같이 보여주기
                        result = "파싱 오류: " + msg;
                    }
                } else {
                    result = "알 수 없는 파싱 오류가 발생했습니다.";
                }
            }
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자페이지 - 회원 대량 등록</title>
    <link rel="stylesheet" href="admin_style.css">
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../img/sharks2.jpg" type="image/jpeg">
    <style>
    body {
      display: block !important;
      justify-content: unset !important;
      align-items: unset !important;
      min-height: unset !important;
      padding-top: 80px !important; /* 네비바 공간 */
    }
  </style>
</head>
<body>
    <jsp:include page="../nav.jsp" />
    <div class="admin-import-box">
        <div class="admin-import-title">회원 대량 등록 (XML Import)</div>
        <div class="admin-import-desc">
            ※ 아래 예시처럼 여러 회원 정보를 한 번에 등록할 수 있습니다.
        </div>
        <form method="POST" class="admin-import-form">
    <div class="admin-import-row">
        <textarea name="xml" rows="10" cols="80" placeholder="예시:
<users>
  <user>
    <id>neo</id>
    <pw>1234</pw>
    <email>neo@sharks.io</email>
  </user>
  <user>
    <id>kim</id>
    <pw>5678</pw>
    <email>kim@sharks.io</email>
  </user>
</users>
"></textarea>
        <button type="submit">회원 정보 업로드</button>
    </div>
</form>
        <div class="admin-import-result-title">파싱 결과</div>
        <div class="admin-import-result"><%= result %></div>
    </div>
</body>
</html>


