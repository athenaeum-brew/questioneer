<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>List of JSP Files</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body>
    <main class="container my-3">
        <a href="admin" target="_admin" style="float:right; text-decoration: none; font-size: 32px;">⬢</a>
        <h1>Questionnaires</h1>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th scope="col">Module</th>
                    <th scope="col">Questionnaire</th>
                    <th scope="col">Lecture</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="file" items="${jspFiles}">
                    <!-- Extract the number using substring and indexOf functions -->
                    <c:set var="mIndex" value="${fn:indexOf(file, 'm')}" />
                    <c:set var="dotIndex" value="${fn:indexOf(file, '.jsp')}" />
                    <c:set var="number" value="${fn:substring(file, mIndex + 1, dotIndex)}" />
                    
                    <!-- Construct the module string and the lecture link -->
                    <c:set var="moduleString" value="module ${number}" />
                    <c:set var="lectureLink" value="https://athenaeum.cthiebaud.com/slides/?${number}.md" />
                    
                    <!-- Display the row in the table -->
                    <tr>
                        <td>${number}</td>
                        <td><a href="${file}">${moduleString}</a></td>
                        <td><a id="lecture" href="${lectureLink}">lecture</a></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </main>
</body>

<script>
    const transformStrings = (str) => {
        const moduleStr = str.replace(/m(\d\d)\.jsp/, 'module $1');
        const urlStr = str.replace(/m(\d\d)\.jsp/, 'https://athenaeum.cthiebaud.com/slides/?$1.md');
        return moduleStr;
        // return { moduleStr, urlStr };
    };
</script>

</html>
