<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // 상위에서 선언된 변수(page 등)가 중복되지 않도록 변수 선언 생략 또는 새로운 이름 사용
    int s_page = request.getAttribute("s_page") != null ? (Integer) request.getAttribute("s_page") : 1;
    int e_page = request.getAttribute("e_page") != null ? (Integer) request.getAttribute("e_page") : 1;
    int total_page = request.getAttribute("total_page") != null ? (Integer) request.getAttribute("total_page") : 1;
    String queryParam = request.getAttribute("queryParam") != null ? (String) request.getAttribute("queryParam") : "";

    // page는 선언하지 않고 request에서 직접 꺼내 쓰기
    int currentPage = request.getAttribute("page") != null ? (Integer) request.getAttribute("page") : 1;
%>

<div class="pagination">
<%
if (currentPage <= 1) {
%>
    <span class="fo_re"> 이전 </span>
<%
} else {
%>
    <a href="index.jsp?page=<%= currentPage - 1 %><%= queryParam %>"> 이전 </a>
<%
}

for (int print_page = s_page; print_page <= e_page; print_page++) {
    if (print_page == currentPage) {
%>
    <strong><%= print_page %></strong>
<%
    } else {
%>
    <a href="index.jsp?page=<%= print_page %><%= queryParam %>"> <%= print_page %> </a>
<%
    }
}

if (currentPage >= total_page) {
%>
    <span class="fo_re"> 다음 </span>
<%
} else {
%>
    <a href="index.jsp?page=<%= currentPage + 1 %><%= queryParam %>"> 다음 </a>
<%
}
%>
</div>
