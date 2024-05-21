package com.cthiebaud.questioneer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;

@WebServlet("/submitAnswers")
public class SubmitAnswersServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        String body = new String(request.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        // Create a unique filename for the student (this is a simple example, you may
        // want to use student ID or other identifier)
        String studentFile = getServletContext().getRealPath("/") + "student_" + System.currentTimeMillis() + ".json";
        System.out.println(studentFile);

        try (FileWriter file = new FileWriter(studentFile)) {
            file.write(body);
            file.flush();
        }

        try (PrintWriter out = response.getWriter()) {
            out.println("{\"status\":\"success\"}");
        }
    }
}
