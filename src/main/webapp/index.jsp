<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <%@ include file="header.jspf" %>    

    <title>Questioneer</title>

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
                <c:forEach var="questionnaire" items="${questionnaires}">

                    <c:set var="_id_" value="${questionnaire.id()}" />
                    <c:set var="_title_" value="${questionnaire.title()}" />

                    <tr id="tr${_id_}">
                        <td>${_title_}</td>
                        <td><a href="https://athenaeum.cthiebaud.com/slides/?${_id_}.md">Slides ${_id_}</a></td>
                        <td><a href="q/${_id_}">Quizz ${_id_}</a></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </main>
</body>

<script>
</script>

</html>
