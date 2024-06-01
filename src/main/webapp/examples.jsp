<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="header.jspf" %>    
    <title>Java Files in GitHub Repositories</title>
</head>
<body>
    <main class="container mt-5">
        <h2 class="mb-4">Java Files in GitHub Repositories</h2>
        <div class="table-responsive">
            <table class="table table-striped table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th scope="col">Repository</th>
                        <th scope="col">Java File</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty applicationScope.githubData}">
                            <c:forEach var="entry" items="${applicationScope.githubData}">
                                <c:forEach var="file" items="${entry.value}">
                                    <tr>
                                        <td>${entry.key}</td>
                                        <td>
                                            <c:set var="url" value="https://github.com/athenaeum-brew/${entry.key}/blob/main/${file}" />
                                            <c:choose>
                                                <c:when test="${fn:endsWith(file, 'pom.xml')}">
                                                    <c:set var="url" value="${fn:substring(url, 0, fn:length(url) - 7)}" />
                                                </c:when>
                                            </c:choose>
                                            <a href="${url}">${file}</a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="2" class="text-center">No data available</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </main>
<!-- Bootstrap JS and dependencies -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
