<%@ page import="java.sql.*" %>
<%
     String DB_SERVER = "jdbc:mysql://mysql:3306/Sharks?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    String DB_USERNAME = "admin";
    String DB_PASSWORD = "student1234";

    Connection db_conn = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        db_conn = DriverManager.getConnection(DB_SERVER, DB_USERNAME, DB_PASSWORD);
    } catch (Exception e) {
        out.println("❌ DB 연결 실패: " + e.getMessage());
    }
%>
