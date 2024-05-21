package com.cthiebaud.questioneer;

import java.io.IOException;
import java.util.concurrent.atomic.AtomicInteger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

@WebServlet("/partial")
public class PartialAnswerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static AtomicInteger goods = new AtomicInteger(0);
    public static AtomicInteger bads = new AtomicInteger(0);

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        JSONParser parser = new JSONParser();
        try {
            JSONObject json = (JSONObject) parser.parse(request.getReader());
            boolean isCorrect = (boolean) json.get("isCorrect");

            if (isCorrect) {
                QuestioneerWebSockets.INSTANCE.broadcast(
                        QuestioneerWebSocketMessageType.GOOD,
                        String.format("%d", goods.incrementAndGet()));
            } else {
                QuestioneerWebSockets.INSTANCE.broadcast(
                        QuestioneerWebSocketMessageType.BAD,
                        String.format("%d", bads.incrementAndGet()));
            }

            response.setContentType("text/plain");
            response.getWriter().write("ok");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        goods.set(0);
        bads.set(0);

        QuestioneerWebSockets.INSTANCE.broadcast(
                QuestioneerWebSocketMessageType.GOOD,
                String.format("%d", goods.get()));
        QuestioneerWebSockets.INSTANCE.broadcast(
                QuestioneerWebSocketMessageType.BAD,
                String.format("%d", bads.get()));

        response.setContentType("text/plain");
        response.getWriter().write("Counters reset to zero");
    }
}
