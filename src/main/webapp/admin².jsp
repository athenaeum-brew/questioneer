<!DOCTYPE html>
<html>

<head>
    <%@ include file="header.jspf" %>

        <title>Dashboard</title>

        <style>
            .custom-progress-bar {
                background-color: #28a745 !important;
            }
        </style>
</head>

<body>
    <main class="container d-flex justify-content-evenly">
        <div>
            <jsp:include page="admin.jsp" ></jsp:include>
        </div>
        <div>
            <jsp:include page="admin.jsp" ></jsp:include>
        </div>
    </main>
</body>