<%@ page import="java.io.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String filename = request.getParameter("file");
    String origin = request.getParameter("origin");

    if (filename == null || filename.trim().isEmpty()) {
        out.println("다운로드할 파일명이 제공되지 않았습니다.");
        return;
    }

    filename = filename.trim();
    if (origin == null || origin.isEmpty()) {
        origin = filename;
    }

    // 한글/특수문자 파일명 대응 (브라우저별 처리)
    String userAgent = request.getHeader("User-Agent");
    String downloadName = origin;
    if (userAgent != null && (userAgent.contains("MSIE") || userAgent.contains("Trident"))) {
        // 구IE 계열: 공백→+, 한글/특수문자 인코딩
        downloadName = java.net.URLEncoder.encode(origin, "UTF-8").replaceAll("\\+", " ");
    } else {
        // 크롬/파이어폭스/엣지(신형): 바이너리로 강제 변환
        downloadName = new String(origin.getBytes("UTF-8"), "ISO-8859-1");
    }

    String uploadDir = application.getRealPath("/userupload");
    File file = new File(uploadDir, filename);

    if (!file.exists()) {
        out.println("요청한 파일이 존재하지 않습니다.");
        return;
    }

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + downloadName + "\"");
    response.setHeader("Content-Transfer-Encoding", "binary");
    response.setContentLength((int) file.length());
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "-1");

    try (
        BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
        BufferedOutputStream bos = new BufferedOutputStream(response.getOutputStream());
    ) {
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = bis.read(buffer)) != -1) {
            bos.write(buffer, 0, bytesRead);
        }
        bos.flush();
    } catch (Exception e) {
        out.println("파일 다운로드 중 오류 발생: " + e.getMessage());
    }
%>
