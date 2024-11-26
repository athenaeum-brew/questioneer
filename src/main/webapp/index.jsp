<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <%@ include file="header.jspf" %>

                    <title>Questioneer</title>

                    <style>
                        th,
                        th>*,
                        td,
                        td>* {
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

                    <style>
                        .exam-subject td {
                            background-color: #d4edda !important;
                            /* light green for exam subjects */
                        }

                        .outside-exam td {
                            color: lightgray;
                            /* background-color: #f8d7da !important;
                            light red for non-exam subjects */
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
                                <th scope="col" class="">Title</th>
                                <th scope="col" class="">Slides</th>
                                <th scope="col" class=""><span>Quizz</span><span style="font-size:24px; color: gray; margin-left: .5rem;">↯</span></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="questionnaire" items="${questionnaires}">

                                <c:set var="_id_" value="${questionnaire.id()}" />
                                <c:set var="_title_" value="${questionnaire.title()}" />
                                <c:set var="_slides_" value="${questionnaire.slides()}" />
                                <c:set var="_examSubject_" value="${questionnaire.examSubject()}" />

                                <tr id="tr${_id_}" 
                                class="<c:if test='${_examSubject_}'>exam-subject</c:if> 
                                       <c:if test='${not _examSubject_}'>outside-exam</c:if>">
                                    <td>${_title_}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty _slides_}">
                                                &nbsp;
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${_slides_}">Slides ${_id_}</a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
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