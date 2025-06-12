<%@ page contentType="text/html; charset=UTF-8" %>
<%
    String BASE_URL = ""; 
    String username = (String) session.getAttribute("username");
    String email = (String) session.getAttribute("email");
    String profileImage = (String) session.getAttribute("profile_image");

    if (profileImage == null || profileImage.isEmpty()) {
        profileImage = "img/profileshark.png";
    }
%>

<nav class="navbar">
    <div class="nav-left">
        <a href="<%= BASE_URL %>/index.jsp">Sharks</a>
    </div>
    <div class="nav-right">
        <img
            src="<%= BASE_URL + "/" + profileImage %>"
            alt="Profile Image"
            class="profile-icon"
            onclick="openModal()"
        >
        <div id="myModal" class="modal">
            <div class="modal-content">
                <div class="profile-info">
                    <img
                        src="<%= BASE_URL + "/" + profileImage %>"
                        alt="Profile Image"
                        class="profile-img"
                    >
                    <% if ("admin".equals(username)) { %>
                        <h2><a href="<%= BASE_URL %>/admin/admin.jsp"><%= username %></a></h2>
                    <% } else if (username != null) { %>
                        <h2><%= username %></h2>
                    <% } %>
                    <p><%= email != null ? email : "" %></p>
                    <a href="<%= BASE_URL %>/mypage.jsp" class="btn">My Page</a>
                    <button class="btn" onclick="location.href='<%= BASE_URL %>/passlogic/logout.jsp'">Logout</button>
                </div>
            </div>
        </div>
    </div>
</nav>
<script src="<%= BASE_URL %>/js/modal.js"></script>
