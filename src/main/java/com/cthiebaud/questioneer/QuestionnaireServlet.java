package com.cthiebaud.questioneer;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { "/q/*" })
public class QuestionnaireServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Get the requested path
        String requestURI = request.getRequestURI();

        // Extract the requested file name (e.g., m01.json, m02.json)
        String fileName = "/questions/" + requestURI.substring(requestURI.lastIndexOf("/") + 1) + ".json";

        String questionnaire = getJsonContentAsString(fileName);
        if (questionnaire == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        } else {
            // Set the file name as a request attribute
            request.setAttribute("questionnaire", questionnaire);

            // Forward the request to the JSP
            request.getRequestDispatcher("/questionnaire.jsp").forward(request, response);
        }
    }

    private String getJsonContentAsString(String path) {
        try {
            JSONParser parser = new JSONParser();

            // Load the file from the classpath
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream(path);
            if (inputStream == null) {
                return null;
            }

            // Convert InputStream to InputStreamReader
            InputStreamReader reader = new InputStreamReader(inputStream, StandardCharsets.UTF_8);

            // Parse the JSON file
            JSONObject questionnaireJson = (JSONObject) parser.parse(reader);

            // Close the input stream
            inputStream.close();

            return questionnaireJson.toJSONString();
        } catch (Exception e) {
            return null;
        }
    }

}
