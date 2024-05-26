package com.cthiebaud.questioneer;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.List;

@WebListener
public class QuestioneerContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();

        context.setAttribute("normalizedContextPath", normalizePath(context.getContextPath()));
        context.setAttribute("questionnaires", List.copyOf(Questionnaires.INSTANCE.questionnaires));
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        ServletContext context = sce.getServletContext();
        context.removeAttribute("questionnaires");
        context.removeAttribute("normalizedContextPath");
    }

    private static String normalizePath(String path) {
        if (!path.endsWith("/")) {
            path += "/";
        }
        return path;
    }
}
