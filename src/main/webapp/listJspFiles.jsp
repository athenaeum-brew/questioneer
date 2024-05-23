<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Questioneer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        th, th > *, 
        td, td > * {
            text-align: center;
            vertical-align: middle;
        } 
        th:first-child,
        td:first-child {
            text-align: start;
        }
        th:last-child,
        td:last-child {
            text-align: end;
        }
    </style>
</head>

<body>
    <main class="container my-3">
        <a href="admin" target="_admin" style="float:right; text-decoration: none; font-size: 32px;">⬡</a>
        <h1>Modules</h1>
        <table class="table table-striped">
            <thead>
                <tr>
                    <th scope="col" class="">Slides</th>
                    <th scope="col" class="">Description</th>
                    <th scope="col" class=""><span>Quizz</span><span style="font-size:24px; color: gray; margin-left: .5rem;">↯</span></th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="file" items="${jspFiles}">
                    <!-- Extract the number using substring and indexOf functions -->
                    <c:set var="mIndex" value="${fn:indexOf(file, 'm')}" />
                    <c:set var="dotIndex" value="${fn:indexOf(file, '.jsp')}" />
                    <c:set var="number" value="${fn:substring(file, mIndex + 1, dotIndex)}" />
                    
                    <!-- Construct the module string and the lecture link -->
                    <c:set var="slidesString" value="Slides ${number}" />
                    <c:set var="quizzString" value="Quizz ${number}" />
                    <c:set var="lectureLink" value="https://athenaeum.cthiebaud.com/slides/?${number}.md" />
                    
                    <!-- Display the row in the table -->
                    <tr id="tr${number}">
                        <td><a href="${lectureLink}">${slidesString}</a></td>
                        <td>&nbsp;</td>
                        <td><a href="${file}">${quizzString}</a></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </main>
</body>

<script>
</script>

</html>
