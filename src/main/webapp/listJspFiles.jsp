<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>List of JSP Files</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <main class="container">
        <h1>Questionneers</h1>
        <ul>
            <c:forEach var="file" items="${jspFiles}">
                <li><a href="${file}">${file}</a></li>
            </c:forEach>
        </ul>
    </main>
</body>

</html>
